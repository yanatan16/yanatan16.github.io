---
layout: post
categories: development code
title: A recommendations algorithm in one query
date: Fri Oct 11 2013 21:41:29 GMT-0600 (MDT)

# Old tumblr stuff
id: 63791286966
link: http://joneisen.tumblr.com/post/63791286966/a-recommendations-algorithm-in-one-query
slug: a-recommendations-algorithm-in-one-query
publish: 2013-10-011
tags: recommendations, collaborative filtering, neo4j
---


Providing recommendations to users generally follows a similar pattern: given a user to provide recommendations for, find users that act similar to that user and recommend things that they do. There are many different places in that statement to tweak and change, which is why it can be so complicated create an effective system. To perform this operation, batch data processing systems such as [hadoop](http://hadoop.apache.org) and [disco](http://discoproject.org) take in all the data, process it into recommendations and export to a realtime system.

These systems give us a lot a flexibility, but the come with a significant amount of overhead. Dealing with this overhead in a startup or a small user-base is way too much. But many times, a recommendation system falls into that “medium data” range where its too large to be effectively done with an in-memory solution, or at least, not without a lot of work.

I’ve heard of others using a graph database to store a graph of user connections and running efficient queries on that data. At its core, the recommendation problem is a graph problem (or at least, it can be). So I figured to try it out.

So here’s how you can use a [neo4j](http://neo4j.org) database to create an efficient realtime recommendations algorithm. (I’ll be showing code for neo4j 2.0, which isn’t stable yet but should be soon.)

Let’s suppose that users buy products. Here’s how we’ll record them.

<code data-gist-id="6945507" data-gist-file="create.cypher"></code>

Now we want to perform a simple [collaborative filtering](http://en.wikipedia.org/wiki/Collaborative_filtering) recommendations algorithm: Find all users that buy the same products as us and recommend the products that they buy, weighted by how many users buy both products the user in question has buyd and the product being recommended.

<code data-gist-id="6945507" data-gist-file="query.cypher"></code>

Line 1 is neo4j boilerplate for starting from a given node (our user). Line 2 is a match pattern that finds a length 3 path between `(u)` and `(p)` with the given node types, relation types and directions. Line 3 says that we shouldn’t recommend from repetitive paths, i.e. those that traverse the same relation twice. Line 4 is our return statement, saying we want to return the projects to recommend (those on the end of the path) and we want to accumulate repeated projects into a count of how many different paths to that project were found. Line 5 is a basic ordering so we get the highest score projects first.

This is a very simple algorithm and many things can be done to make it more complicated, for instance adding weights or different types of relations and nodes. Happy recommending!

