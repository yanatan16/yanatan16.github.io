---
layout: post
categories: programming
date: Sun Sep 21 2014 11:27:23 GMT-0600 (MDT)
title: My perfectly scalable system
redirect_from: /post/98069470756/

# Old tumblr stuff
id: 98069470756
link: http://joneisen.tumblr.com/post/98069470756/my-perfectly-scalable-system
slug: my-perfectly-scalable-system
publish: 2014-09-021
tags: deployments, scalability, CRDT, polylithic, work queues, queues, pub/sub, publish/subscribe
---


This is my idea of a perfectly scalable system that I would build. Someone could and will argue about each point. The system I’m describing is a generic backend architecture.

I should note that my definition of “scalability” includes scaling development teams (including turnover) as well as linearly scaling \#boxes/request.

### Polylithic application

Polylithic is the opposite of Monolithic. This means your whole application is made up of individual subapplications that are individually developed and deployed for a single (or small number of) purpose(s). While a monolithic application can standardize practices and reduce repetitive code, a good module system can do the same. The advantages of many small apps are many. You can scale a single app up to handle load that only it is seeing an increase in. For instance, CNN doesn’t need to scale up their emailer when a large news event happens, only their apps serving the main pages. In addition, it is easier to *grok* a small app and understand everything that is going on. This leads to better ability to jump into a new part of the code for new people and more confidence when making changes, because they are easier to reason about. Its also much easier to test.

### Work Queues

Work queues are amazing. If you can setup a reliable work queue (that is, one that once data is confirmed in the queue, its got a high priority of being processed), you can significantly hide much of your architecture from the clients who are requesting work from you. A large processing task, or even small ones, become simple pushes into the queue, where a worker will then pull them out when one is ready. These can help you withstand spikes in traffic (or the opposite, crashes in processors). They can help you replay data when bugs occur. This is the cushion of processing-based systems.

### Messaging infrastructure

You have a polylithic architecture. Now you have to communicate between these small apps. Whats the best way? In my opinion, its reliable delivery pub/sub. Publish/Subscribe mechanics allow decoupling of a sender from its receiver, allowing you to do cool stuff like [Samza](http://samza.incubator.apache.org/), which builds stream processing in between publisher and subscriber. In addition many messaging systems can be used as work queue systems so there’s reuse (less chances for failure). Alternatives include RPC, HTTP, and direct messaging (like 0MQ). The advantage of pub/sub is you can use an individually scalable broker to pass messages to whoever wants or needs them. This means more messages and more events flowing through your system. That means more data to play with and an easier time getting it.

P.S. I highly suggest [Kafka](http://kafka.apache.org/), but alternative abound.

### CRDTs

CRDTs are a relatively new area of research. It means Commutative Replicated Data Types. Essentially by using only CRDTs as your only data stores (or the highly real-time ones), you make the problem of replication and eventual consistency MUCH easier. Many CRDTs are set operations like union. A bunch of union operations can be applied duplicated and in any order and still come out with the same result. This means less distributed locks and more time getting and setting data. And that means near-linear scaling.

The best paper for CRDTs is [here](http://hal.upmc.fr/docs/00/55/55/88/PDF/techreport.pdf) and [Basho has a talk](http://basho.com/tag/crdts/) and SoundCloud built [Roshi, a fast distributed CRDT store](https://github.com/soundcloud/roshi).

### Automated Testing

Everyone talks about this one but its really really true. Test your code from unit to integration to load testing. Test it all the time. Test it automatically. Show the results of the test prominently where everyone can see. The impacts are many: shorter time to make changes, stop bad code from getting out, *correct* documentation, more confidence.

### Easy Deployments

I have a theory of developers. If its easy, they’ll do it. If its hard, the won’t. And while that theory probably isn’t groundbreaking, its my philosophy when developing tools for developers. So when I make a deployment system, I make it easy to use. Either chat-based or CLI-based or web-based, it doesn’t really matter. All that matters is that I should be able to push a change and deploy it in a matter of minutes without thinking about the process. One must of course think about monitoring post-deploy, but the act of deploying should be a red-button “one-click and go” kind of thing. This also implies reliable deployments, so they shouldn’t fail a lot. If they do, go back to the drawing board. If you have easy and reliable deployments, new developers and old will never feel uncomfortable once learned. You will also deploy faster, which is always good to notice errors faster and fix faster, etc.

And thats the core of my dream system. I am always striving to improve the systems I work on to get there.
