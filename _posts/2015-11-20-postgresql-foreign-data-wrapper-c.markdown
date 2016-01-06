---
layout: post
section: index
title: A Guide to Native PostgreSQL Foreign Data Wrappers
categories: tech
date: 2015-11-20 23:00:00
---

I spent the last few weeks creating a PostgreSQL Foreign Data Wrapper (FDW). I wanted to record a bunch of things I learned along the way. Many of the reasons why the FDWs are structure in the way they are lightly documented, so this should help those looking to build these in the future.

<!--break-->

I'll be covering only `SELECT` and `EXPLAIN` in this post, as I don't currently have any experience implementing the other operations. I'll be focusing on the reasoning and *why* of implementing the FDW, as opposed to massive code snippets. Reading some of the source code should help you understand the exact code required to implement the FDW.

Some FDWs are very simple and do not implement the functionality described. But, if the FDW is complex and pushes down as much work as possible to the remote data source, then this is really the simplest possible architecture.

Note also that I am covering a native C implementation. I do not have experience with the python ([multicorn](http://multicorn.org/)) or ruby ([holycorn](https://github.com/franckverrot/holycorn)) wrappers around the FDW interface.

## What is a FDW

A FDW is a Postgres extension that allows one to query a remote data source through Postgres. In addition to querying the remote data source, a FDW can leverage Postgres' internal executor engine to get more features than the underlying data store can actually support. For instance, the [s3_fdw](https://github.com/umitanuki/s3_fdw) reads CSV files from s3. One can use the s3_fdw to join two CSV data sets.

But, in cases where the remote data source can handle advanced restrictions and sorting mechanisms, it makes sense to "push down" the work as close to the data as possible. For instance, the [oracle_fdw](https://github.com/laurenz/oracle_fdw) pushes down a number of WHERE clauses to the Oracle SQL database being queried, instead of returning with all the rows and having Postgres do the work, which would be more costly.

## Query Planning

The first step in handling any query is planning how the query will be executed. Many queries only have one possible execution strategy, but some have more. Estimating the size of the relation is paramount in Postgres' planner to determining the execution strategy. In (inner) joins for instance, if one of the relations will only return a very few number of rows, the planner can optimize to a less costly type of execution compared to another.

First, the planner asks the FDW to estimate the size of scanning the table (with appropriate pushed down restriction clauses), then it asks the FDW to establish the different strategies it could take to satisfy the query in question, each with an estimated cost. Finally, the planner chooses a path, and asks the FDW to prepare a query to be executed.

### Estimating the Table Size

In the `GetForeignRelSize` callback function, the FDW must establish the `startup_cost` and `total_cost` of executing a table scan of the remote table, possibly pushing down any possible restriction (WHERE) clauses to the remote data source.

```c
Cost startup_cost = FDW_STARTUP_COST; /* something high, like 100 */
Cost per_tuple_cost = FDW_TUPLE_COST; /* something low, like 0.01 */
Cost nrows = estimate_number_of_rows(relation);
Cost total_cost = startup_cost + nrows * per_tuple_cost;
```

To identify which clauses can be pushed down, see the [Walking the Expression Tree](#walking-the-expression-tree) section.

### Creating Query Paths

In the `GetForeignPaths` callback function, the FDW must parse out the query and determine if any alternate query paths can be taken, and estimate their cost for the planner. By doing some work already in `GetForeignRelSize`, the FDW already knows the cost of a basic table scan including pushed down restriction clauses.

```c
path = create_foreignscan_path(root, baserel,
                               fpinfo->rows,
                               fpinfo->startup_cost,
                               fpinfo->total_cost,
                               NIL,                 /* no pathkeys */
                               NULL,                /* no outer rel either */
                               NIL);                /* no fdw_private list */
add_path(baserel, (Path *) path);
```

The first alternate path to consider is whether the remote data source can sort the data as requested by the query. These are stored in what Postgres calls pathkeys. These essentially represent the `ORDER BY` clause.

If the remote data source can sort the data as desired by the pathkeys, then Postgres won't have to do an in memory sort. Along with declaring this path, the FDW should also calculate the cost of that remote sort. For instance, if the sort is on an indexed field, the sort could be basically free, but otherwise would be similarly costly to Postgres, who might just choose to sort the data itself if it would save time.

Additionally, if the remote data source cannot sort by _all_ the pathkeys, then it is better to not sort at all because the Postgres executor isn't sophisticated enough to save time when the data comes in partially sorted.

```c
foreach (lc, root->query_pathkeys)
{
    if (pathkey_is_handleable((PathKey *)lfirst(lc)))
        usable_pathkeys = lappend(usable_pathkeys, (PathKey *) lfirst(lc));
    else
    {
        /* Partial sorts are useless */
        usable_pathkeys = NIL;
        break;
    }
}

if (usable_pathkeys != NIL)
{
    /* estimate scan with pathkey sorting cost */
    path = create_foreignscan_path(root, baserel,
                                   rows,
                                   startup_cost,
                                   total_cost,
                                   usable_pathkeys,
                                   NULL, /* no outer relations */
                                   NIL));
    add_path(baserel, (Path *) path);
}
```

The second set of alternate paths are based on join conditions. For each join condition (such as `z1.id = z2.id`), the FDW should estimate the cost of a **parameterized path**. A parameterized path is a query where the join condition is replaced by a variable substitution. Consider the equivalence relation given above, the parameterized path for the `z1` relation is `z1.id = $1`, with `$1` evaluated at execution time.

```c
    /* Figure out if we can do any join parameterized path */
    ParamPathInfo *param_info;
    path = create_foreignscan_path(root, baserel,
                                   rows,
                                   startup_cost,
                                   total_cost,
                                   NIL,             /* no pathkeys */
                                   param_info->ppi_req_outer, /* outer relations */
                                   NIL);    /* no fdw_private list */
    add_path(baserel, (Path *) path);
```

Postgres will then consider the costs of each query and combine them in such a way as to minimize total cost. It is important to go through this process and not just choose one best query path because join information is not fully given to the FDW, and thus the only way to optimize them is to work with the Postgres planner engine.

#### Possible JOIN Executions

Depending on the relative costs of two join relations full scans and parameterized scans, Postgres' planner will decide how to execute the JOIN. In my experience (only as an FDW writer, not a Postgres core developer), there are three options:

- Merge join. This involves full table scans of both relations, in-memory sorts of both by their join keys, and a merging of the two data sets into the final output. This is usually done when both datasets are of similar large size, or a hash join is impossible because of the join condition.
- Hash join. This involves no sort, but the operation on a per tuple basis is more costly. If the join is done on an equivalence condition (`x = y`), then by hashing each value of the join fields from both relations, Postgres can merge the data sets without a sort.
- Parameterized Path Nested Loop. This involves no sort and is usually the fastest when very few rows are returned. Basically, the relation with very few rows done is executed, then with the few rows' values for the join fields, the second relation is executed with the values as parameters.

This is why its so important to work with the planner, because if the FDW didn't go through the process of giving the planner each possible query path, every time you wanted to JOIN with a very specific WHERE clause, the FDW would pull back the entire dataset, instead of just a couple rows.

### Preparing the Remote Query

Finally in the planning process, Postgres will call the `GetForeignPlan` function with information about the chosen query path. Here, the FDW is supposed to wrap up any query planning tasks by actually building the query to be executed later. The FDW then stores this information in a linked list which is carried across memory contexts for later use in one of many different functions (SELECT, EXPLAIN, UPDATE).

```c
fdw_private = list_make1(makeString(query));

return make_foreignscan(tlist,
                        local_exprs, /* restrictions for Postgres to handle */
                        baserel->relid,
                        params_list, /* List of parameterized expressions */
                        fdw_private); /* List of private data */
```

### Walking the Expression Tree

In order to figure out which expressions are executable in the remote data source, as well as rendering the query to be sent to the remote data source, the FDW must walk the expression tree recursively.

```c
/*
 * Identify which baserestrictinfo clauses can be sent to the remote
 * server and which can't.
 */
classifyConditions(root, baserel, baserel->baserestrictinfo,
                   &remote_conds, &local_conds);
```

Each expression (such as in a restriction clause, a selection clause, an ordering clause, or join condition) is a Postgres `Node`, which has an enumerated type. The FDW will have a big `switch` statement, enumerating each type that the remote data source supports. Each `case` statement will handle the type in question, checking to make sure it is handleable, and recursively calling for that type's children, if any. A special case is column references, where the FDW must determine if the reference comes from the table in question.

```c
switch (nodeTag(node))
{
case T_Var:
    /* do stuff for a variable (column) */
    break;
case T_Const:
    /* do stuff for a constant (literal) */
    break;
case T_FuncExpr:
    /* do stuff for a function */
    break;
case T_OpExpr:
    /* do stuff for an operator */
    break;
/* more stuff ... */
```

When rendering the query to be sent to the remote source, massive transformation might be needed, or very slight transformation. The important parts are operations, like `=`, `~~`, and `+`; and functions like `concat` and `length`. Once the FDW ensures that those parts art translated correctly to the remote data source, the rest is mostly boilerplate.

## Query Execution

Now that the FDW has planned its query out, its time to execute it. This is organized into a call to begin a foreign scan. Then successive calls to iterate on that scan should return a single row (or tuple). Finally, the scan can be ended or told to rescan, with possibly different parameters.

### Query Execution

If a `SELECT` or `UPDATE` was called, Postgres will ask the FDW to execute the query.

Here, in `BeginForeignScan`, the FDW allocates any contexts it needs and begins the scan of the remote data source with the query prepared in the planner. This is the only opportunity to allocate a large memory location that will last the entire query.

```c
/* Get the query out of the list of private data */
char * query = strVal(list_nth(fsplan->fdw_private, 0));
```

If the query involves variables from paramterized path joins, the parameters will be executed into values here, so as to be included in starting the query.

In `IterateForeignScan`, the FDW returns a single tuple to the executor. Usually, a batch of tuples is stored in memory pre-allocated, and simply copied at this stage unless more tuples are needed.

```c
/* First clear the tuple */
ExecClearTuple(slot);

/* If data is found, fill the tuple */
ExecStoreTuple(tuple, slot, InvalidBuffer, false);
```

In `ReScanForeignScan`, the FDW should rewind the scan back to the beginning. Sometimes, runtime parameters will have changed, so the overall query might need to change.

In `EndForeignScan`, the FDW closes all open files and connections that might still be open from the scan. If a `LIMIT` clause was used, there could be data still to be read in, and all this should be discarded.

## Query Explanation

If an `EXPLAIN` statement was called, Postgres will not call the `BeginForeignScan` function, and will instead call `ExplainForeignScan`. If the FDW supports `EXPLAIN`, it should render that information here.

```c
ExplainState *es;
ExplainPropertyText("Remote Data Source Query", some_query, es);
```

## Other Resources

- The best resource is source code. The best source code is embedded in the project itself. Check out the [postgres_fdw](https://github.com/postgres/postgres/tree/master/contrib/postgres_fdw), which is maintained alongside Postgres and is featureful. I suggest that any featureful FDW be copied from this example, as it follows all the proper conventions and doesn't take shortcuts.

- [Official Writing an FDW documentation](http://www.postgresql.org/docs/current/interactive/fdwhandler.html).

- I wrote the [quasar_fdw](https://github.com/yanatan16/quasar_fdw), which is in many ways similar to the postgres_fdw, but does show how the FDW must sometimes transform operators from one SQL syntax to another.

- The [Foreign Data Wrappers wiki page](https://wiki.postgresql.org/wiki/Foreign_data_wrappers) has a large list of links to FDWs and help articles.

- The [blackhole_fdw](https://bitbucket.org/adunstan/blackhole_fdw) is a great way to get started writing your own FDW. It sets you up with the build system and allows you to start testing queries immediately.

- [gleu's blog on validating options in an FDW](http://blog.guillaume.lelarge.info/index.php/post/2013/06/25/The-handler-and-the-validator-functions-of-a-FDW) is helpful for that aspect.
