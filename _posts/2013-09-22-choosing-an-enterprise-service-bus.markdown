---
layout: post
categories: development architecture
title: Choosing an Enterprise Service Bus
date: Sun Sep 22 2013 13:44:00 GMT-0600 (MDT)

# Old tumblr stuff
id: 61988455027
link: http://joneisen.tumblr.com/post/61988455027/choosing-an-enterprise-service-bus
slug: choosing-an-enterprise-service-bus
publish: 2013-09-022
tags: distributed computing, enterprise service bus
---


This article is cross-posted on
[make.rafflecopter.com](http://make.rafflecopter.com/enterprise-service-bus.html).

The core of any distributed system is the Enterprise Service Bus (ESB).
Its how the disparate, coupled components communicate, either through
request/reply semantics or asynchronous messaging. Whether your building
a web app, a SAAS, a PAAS, or a radar, distributed systems are the right
way to go.

First, a moment on why distributed systems are so popular. Distributing
your system (as opposed to a monolithic application) will decrease
performance due increased overhead (i.e. time on the ESB versus a simple
function call). But it will allow increased concurrency, easier
development (like functional programming, composing smaller parts is
easier), better management (individual services can be updated without
taking down the system), and the ability to scale (buzz word!). Scaling
does not just mean in users, but also in developers, as multiple
composed services will be easier for larger teams to develop on (see:
Amazon).

Distributing your system has benefits, but the key for success is making
the tradeoff decisions to maximize the benefits you care about. There
are primary tradeoffs to think about when choosing an ESB: communication
pattern and broker.

#### Communication Pattern: [Remote Procedure Call (RPC)](http://en.wikipedia.org/wiki/Remote_procedure_call) vs [Publish/Subscribe (Pub/Sub)](http://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern)

In RPC, each communication requires a response which may be waited for
in a synchronous or asynchronous way. The pub/sub pattern is a system
where messages are sent (published) asynchronously on channels which are
subscribed to by other applications on the network. There are other
minutia to consider, but these are the primary two patterns. RPC implies
your communications need responses from specific endpoints, whereas
pub/sub implies that communication is undirected, that is, messages are
not sent to direct places, only on channels where others may be
listening.

#### Brokered system

The biggest problem in managing and monitoring a distributed system is a
constantly changing topology, or map of how applications communicate.
Whether your running 5 services with 2 instances each, or 1000 services
with 10,000 nodes, topology will change. In order to manage the topology
as it changes, a broker is very useful. A broker is a central place(es)
where all nodes connect to in order to communicate. Brokers can be
proxies for messages or can be discovery services that allow nodes to
connect to each other. Brokers help improve topology management by
reducing the work that users have to do. Proxy brokers can help
monitoring by having a central place to keep track of traffic and usage
of the ESB. Proxy brokers are the most popular of brokered systems
because of the great tooling and monitoring it provides (see:
[RabbitMQ](http://www.rabbitmq.com/) and [Redis](http://redis.io/)).
Unbrokered systems such as
[CORBA](http://en.wikipedia.org/wiki/Common_Object_Request_Broker_Architecture)
and [OSGi](http://www.osgi.org/Main/HomePage) have increased wire
performance, but use discovery services to find other endpoints, which
can increase wire traffic.

Every system has different requirements, and different tradeoff
decisions are made. As we at [Rafflecopter](http://rafflecopter.com)
expand our system, we want to nail down our ESB. We’re building and
expanding a web application with a scaling number of users and backend
systems such as analytics, recommendations, and social connections. For
a system like this, we chose the pub/sub pattern because asynchronous
communcation will be the core unit of communication in the system. If
request/reply semantics are needed in the rare case, we’ll use http.
Additionally, we don’t fall into the “needing extreme performance”
group, so we decided to stick wth a brokered system.

Back when I used to work for the government doing embedded computing, we
made different choices, going with a brokerless sysytem and a binary
protocol for the bare-bones speed requirements and giving both RPC and
Pub/Sub patterns available. But in today’s world of big servers and
complicated applications running in the milliseconds (not microseconds),
the advantages of a brokered system weigh heavily in the tradeoff
decision.

