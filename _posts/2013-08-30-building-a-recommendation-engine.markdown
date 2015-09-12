---
layout: post
section: index
categories: development
title: Building a Recommendation Engine
date: Fri Aug 30 2013 08:45:09 GMT-0600 (MDT)
redirect_from: /post/59775425253/

# Old tumblr stuff
id: 59775425253
link: http://joneisen.tumblr.com/post/59775425253/building-a-recommendation-engine
slug: building-a-recommendation-engine
publish: 2013-08-030
tags: recommendations, under armour, disco, hadoop, rest, golang, collaborative filtering, mapreduce
---


This is the first post in a 2-part series on how I built a recommendations engine for [Under Armour](http://www.underarmour.com). This post details how I was introduced to the project, the overall design, and the algorithm. A follow-up post will go over lessons learned from building the system.

Essentially, the leadership last year decided that we could probably get more versatility, integration and similar performance from our own recommendations system rather than a third party’s. By versatility, they meant more specific algorithms that fit with Under Armour’s user behavior and purchase patterns. By integration, they essentially meant less sold out and clearance products showing up by mistake, and faster speed performance in recommendation zones. They still expected a similar revenue performance. My boss came to me and suggested we start building a new system to give in-house recommendations to compete with our vendor’s.

We started with no user data (UA uses a third party analytics which isn’t too forthcoming with data), no data processing system (e.g. Hadoop, Storm), and no idea of how to create a recommendations system.

The first thing we had to do is get user data by introducing a tracking system other than our analytics vendor. We setup a simple Go REST service logging to a database, and sent it off tracking data for a few months.

Secondly we had to figure out how user data would be stored, processed, and recommendations created. Most recommendation systems use a backend processing engine to process the data into an easily digestable form for the recommendations runtime. Clearly the obvious choice is Hadoop. But I hate Java. I hate the classpath; I hate the lack of expressiveness; I hate folder structure; I hate the obsessive object-oriented system; and I hate the documentation. I installed Hadoop and loaded [Dumbo](http://klbostee.github.io/dumbo/), which a python API for the Hadoop Streaming API. I loved that I got to use python to program on Hadoop, but the Hadoop streaming API is a hack, and slowly problems started creeping up due where I had to program Java to bridge the gap. Configuration was becoming a task, and I was the only one who would be managing this cluster (we’re all generalists). I started to look for a different option.

That’s when I found [disco](http://discoproject.org) (thanks [Erlang!](http://twitter.com/ErlangInfo)). Disco is a Hadoop alternative with a Python API built on top of an Erlang backend. The project is young, but very usable. I loved the interface and quick start so much. There is no Mahout on Disco though, so I had to build the algorithms myself, but the experience was so seemless it didn’t matter. By the end of my experience with Disco, all the problems I had with it due to its young nature were about equal to the complexity problems I would have probably encountered with Hadoop. In the end, all is probably equal, but I enjoyed programming for disco much more. Disco also has a mongo connector, which I improved, but haven’t fully pull requested it yet
([yanatan16/mongo-disco](http://github.com/yanatan16/mongo-disco)).

Finally, we needed an algorithm to use. I browsed google scholar and IEEE Xplore for recommendations algorithms. There are a few options, of which [Wikipedia - Recommender System](http://en.wikipedia.org/wiki/Recommender_system) can give you an overview. We ended up choosing [Collaborative Filtering](http://en.wikipedia.org/wiki/Collaborative_filtering), specifically Item-to-Item collaborative filtering, as designed [by Amazon](http://www.cs.umd.edu/~samir/498/Amazon-Recommendations.pdf). We chose this because UA has a lot of guest traffic, which means if we went with a user-based method, many of our guest users would get bad recommendations. By using an item-based system, we can provide good recomendations to new users very early in their experience.

Basically, given that a user has purchased/rated/viewed/etc two items, those two items are related somewhat, so increment a relatedness value. Go through all your users’ interactions and do this. Then you’ll have a matrix of the affinity between products. Then use one of a few methods to boil that down to a matrix of similarity values (dot product, cosine, Pearson correlation, etc). Once you have that, you can export a list of similar products to a database on a per-product basis. Once you have an ordered list of similar products for each product, you can easily create item-based recommendations in your application runtime.

Thats the basic anatomy of a Recommendations Engine. In a follow-up post, I’ll go over how I built the internal components and do a side-post on programming with disco.

