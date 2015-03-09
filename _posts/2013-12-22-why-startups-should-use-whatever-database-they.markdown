---
layout: post
categories: development architecture
title: Why startups should use whatever database they want
date: Sun Dec 22 2013 10:48:13 GMT-0700 (MST)
redirect_from: /post/70801899961/

# Old tumblr stuff
id: 70801899961
link: http://joneisen.tumblr.com/post/70801899961/why-startups-should-use-whatever-database-they
slug: why-startups-should-use-whatever-database-they
publish: 2013-12-022
tags: database, relational database, SQL, NoSQL, MongoDB, CouchDb
---


I just read this article about why [startups should use relational databases](http://raycmorgan.com/e/startups-should-use-relational-database.html) by Ray Morgan. Ray seems like a good developer judging from his [github profile](https://github.com/raycmorgan). There are some good thoughts in the article, but I disagree with the main point. For reference purposes, when I talk about schemaless datastores, I’m going to be referring to databases that solve the same problems as relational databases, such as MongoDB, CouchDB, etc.

Let’s start with a quote from the article.

> At some point, you will need to ask your primary database questions.
> If you chose the wrong database, this is where things get tricky. This
> is why I suggest startups should use a relational database. Relational
> databases are fundamentally developed around this problem. It means
> less mucking around with crazy map/reduce queries and more time spent
> solving problems and getting answers.

How does one query a relational database? By creating convoluted advanced SQL queries. How does one query a schemaless database? By creating convoluted map-reduce queries or convoluted scripts executing simple database calls. Both methods require a lot of knowledge of the database being used, a lot of knowledge about the language being used (SQL or javascript primarily), and a lot of knowledge on the schema of the data (yes schemaless databases have schema, its just not written down). These two methods are equivalent.

SQL and scripting are two sides of the same coin. Relational databases decided they would tackle the hard problem of data querying by writing a lot of code in their query engine and creating a language for those queries. Schemaless datastores punted on creating querying capability and just decided to make it really easy to write arbitrary map-reduce or scripting in javascript (probably the most well known scripting language out there). Does it require less knowledge or experience to make advanced queries on either system? No.

The datastore type you should choose should be based on the ability for people (and robots) who will use it. If you’re going to have a lot of business people who have prior experience with SQL querying your database, then you should probably go relational. If you are a node.js shop and you’re team will be doing the data science, go for Mongo or Couch.

My point is one datastore is not better than the other. You will do the same amount of work on your database over time. It is easier to setup Mongo but [slightly] harder to migrate. It is easier to do simple queries but [slightly] harder to do advanced queries. Scaling is just plain hard for both types. So pick your database based on the people.

