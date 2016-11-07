---
title: Thoughts on Kafka Connect
layout: post
section: index
date: 2016-11-07 12:00:00
---

[Kafka Connect][1] is a really cool technology. At its core, its a processing cluster for ingesting and digesting data from a database to kafka. But its goal is greater: it aims to make it easier for developers to use Kafka in the first place. Confluent wants to make it simple to pull data from a datastore like S3 **writing no code**. Pulling (*Source Connectors*) and pushing (*Sink Connectors*) to and from a streaming data system is very common. Additionally, it is generally some of the first tasks any developer will do when starting to work with Kafka.

<!--break-->

The implementation of Connect is perhaps even more laudible than its goals. Connect manages parsing of messages in a separate layer than the Connectors (called *Converters*), even providing Avro and JSON with schemas by default with version 0.10. This allows a Connector developer to not worry about encodings when developing, and allows teams with custom message encoding to use standard Connectors. Furthermore, Connect handles the logic of offset committing and describes methods to get exactly once delivery so that Connector developers only need knowledge of the remote system, not deep knowledge of Kafka itself.

Alas, there has to be a downside, and it is the age of the ecosystem. To be successful, Connect will rely on a rich ecosystem of Connectors and Converters. Currently, the APIs are moving too fast for most developer to keep up. Like most FOSS projects, these connectors often solve a single use case for the author and only later go on to satisfy general population use cases. At this point, either connectors aren't keeping up or they don't solve your exact use case.

This leaves you one option for now, write your own! It's not that hard and there is good [documentation][1].

I've been writing some Sink Connectors in clojure recently, and I'll go into detail in a future post. Stay tuned!

[1]: http://docs.confluent.io/2.0.0/connect/
