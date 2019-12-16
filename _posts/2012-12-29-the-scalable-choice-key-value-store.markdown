---
layout: post
categories: programming
title: "The Scalable Choice: Key-Value Store"
date: Sat Dec 29 2012 04:32:21 GMT-0700 (MST)
redirect_from: /post/39120972753/

# Old tumblr stuff
id: 39120972753
link: http://joneisen.tumblr.com/post/39120972753/the-scalable-choice-key-value-store
slug: the-scalable-choice-key-value-store
publish: 2012-12-029
tags: database, mongodb, riak, cassandra, cloudant, bigtable, dynamo, scalability, multi-datacenter, voldemort, nosql, rdbms, key-value store
---


With the wave of NoSQL Databases created to solve the scalable performance problem, most of them have were created as Key-Value Stores, a database which stores keys in a large hash-table or dictionary, as opposed to a collection or table. A few have kept remnants of the RDBMS model, specifically MongoDB.

At Under Armour, we currently use MongoDB for most of our database needs, from CMS-controlled content, to compiled product data, and even long-term session data. We are also in the midst of researching the next generation platform of [UA.com](http://ua.com). One of our main discussions is database choice. Many people have ranted about MongoDB’s problems, so I won’t do that here, suffice to say its problems with scalability and operations weigh against its ease of use.

Our management team has decided the next platform should be global, which makes sense as a global company, to be able to open up shop in data centers across the globe. Our primary focus should be to make sure we can operate in an Active-Active configuration, that is, multiple data centers serving requests for the same content simultaneously. This is as opposed to a Failover configuration.

In order to satisfy this business and technological goal, we need to choose a database that can support multiple disparate data centers or build a layer ourselves on top (a less desirable option). After a wide search, we reconsidered most NoSQL database options and came up with this list: [Riak](http://basho.com/products/riak-overview/), [Cassandra](http://cassandra.apache.org), [Cloudant](http://cloudant.com), and [Voldemort](http://www.project-voldemort.com/voldemort/) (If I’ve missed one, please let me know in the comments section). One thing you’ll immediately notice is that all of these are Key-Value Stores, of which MongoDB and RDBMS systems are not.

Why are Key-Value Stores the inherent choice for large scalability? Even Google’s new super scalable datastore [Spanner](http://research.google.com/archive/spanner.html), which has a semi-relational API, is a Key-Value store underneath the covers ([Datomic](http://www.datomic.com/overview.html) will wrap a semi-relational API on top of a Key-Value Store as well). Lookups in an RDBMS involve table-scans with pre-indexed orderings. That means that nothing in a table can change during a lookup, also that only one change can happen at the same time in a table (known as locking). Lookups in KVS only affect one key, thus locking is significantly reduced, which is a boon for scalability. Imagine trying to acquire a lock against a database spread across the world, it would take seconds before the transaction completed. With a KVS, you can get rid of locking altogether by introducing timestamps on data and allowing eventual consistency.

Reduced locking allows multiple “master” nodes (aka a “headless” cluster), which then allows for partition tolerance and high availability. Multi-data center is just one more layer of indirection above that, introducing latency-aware replication schemes. There are a myriad of other reasons for going to a KVS, and I’m not really an expert, so I’ll refer you to the [BigTable paper](http://research.google.com/archive/bigtable.html) and the [Dynamo paper (pdf)](http://www.allthingsdistributed.com/files/amazon-dynamo-sosp2007.pdf) for some expert opinion on the subject.

When we move to a Key-Value Store, we’ll be moving from MongoDB, which will be step down in usability, because we lose the abstraction of querying. However, the advantages in scalability and administration will be significant enough to outweigh the costs. The choice almost seemed inevitable from our first thoughts about the next evolution of our datastore. As our user base scales globally, we have to scale our website to service those around the world.
