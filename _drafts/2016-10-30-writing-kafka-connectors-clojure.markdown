---
title: Writing Kafka Sink Connectors in Clojure
layout: post
section: index
date: 2016-10-30 12:00:00
---

I've been writing Kafka Connect Sink Connectors in Clojure for some specific use cases and I'd like to share some of the work I've done. For now, I'll focus on implementing basic Sink Connectors only, as I haven't written a highly dynamic Sink Connector or a Source Connector yet.

## Basics

Kafka Connect has a Java API for implementing Connectors. Simply implement two classes and put them in a JAR to use them in Connect. Let's consider the two classes:

``` java
public abstract class SinkConnector {
  public void start(Map<String,Object> config);
  public void stop();
  public Class taskClass();
  public ConfigDef config();
  public List<Map<String,Object>> taskConfigs(int maxTasks);
}

public abstract class SinkTask {
  public void start(Map<String,Object> config);
  public void stop();
  public void put(List<SinkRecord> records);
  public void flush(Map<TopicPartition, long> offsets);
}
```

**Note**: I am skipping a few functions that would be used for making highly dynamic Connectors. See the documentation for those.

Like many clojurists, I see a lot of cruft in that API. In fact, I see only 2 highly important functions: `taskConfigs` and `put`. The rest are optional at best and repetitive to implement all the time.

## Franzy Connect

[Franzy][1] is an awesome open source project for working with Kafka from Clojure. As I started to work with Kafka Connect's Java API, I felt the need to extract my learnings into a clojure library. I felt that this library would fit in nicely next to the rest of Franzy's offerings.

Implementing a java class in clojure requires the use of the `gen-class` macro, as well as ahead of time compilation (`:aot :all`). Franzy connect wraps that cruft for you, allowing you to just write clojure functions to do the necessary work. Furthermore, it only requires a config definition and a put function to work, allowing you to start small and build functionality and dynamicism over time.

**Note**: Franzy Connect is a young project that needs more time to be fully featureful. It is possible to write any kind of SinkConnector now, but the API is not locked and documentation is incomplete.

## A Basic Sink Connector

Let's make a super-basic sink connector, the Print Sink!:

``` clojure
(require '[franzy.connect.sink :as sink]
         '[franzy.connect.config :refer [make-config-def]
         '[clojure.tools.logging :as log])

(sink/make-sink
 org.clojars.yanatan16.kafka.connect.print.PrintSink
 ;; The Task Options
 {:put-1 (fn [_ record] (log/infof "Got a Kafka Record: %s" (pr-str (:value record)))}
 {:config-def (make-config-def)})
```

Here's what Franzy Connect will do with that small piece of code:

- Generate the class `org.clojars.yanatan16.kafka.connect.print.PrintSinkConnector` implementing `SinkConnector`
- Generate the class `org.clojars.yanatan16.kafka.connect.print.PrintSinkTask` implementing `SinkTask`
- For both classes, it will create an atom to hold the state of the connector. The state will be passed into each function as the first argument, and reset with the return value.
- For both classes, it will make a `start` function that returns the configuration as the state.
- For the configuration and records from Kafka, the library will automatically convert java data structures into clojure ones, allowing you to use keywords and destructuring to address your configuration values and records.
- `SinkConnector.taskClass` will automatically be created to point to `SinkTask`
- `put-1` will be wrapped into a batched version `(put [state records])`

You can then compile that into an uberjar and use it as a connector, in fact I do this for integration [testing](https://github.com/yanatan16/franzy-connect/blob/master/docker-compose.yml).

## Future

This post introduced the project and showed a simple way to use it. In future posts, I'll detail how to do more complex things like making ConfigDefs, handling retries, and building SourceConnectors. Stay tuned!
