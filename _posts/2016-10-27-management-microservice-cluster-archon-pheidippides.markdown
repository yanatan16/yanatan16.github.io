---
title: Managing a microservice cluster
layout: post
categories: programming
date: 2016-10-27 12:00:00
---

I've been managing medium-sized microservice clusters for a while now. Managing these systems has never felt right to me; most of the time it sucks. Often the management tooling has been strewn between many apps and been either not featureful enough or too developer-focused. At Activision, I'd like to try and end this streak.

<!--break-->

When I talk about a microservice cluster, I'm talking about one or more distributed compute clusters and one or more databases that users deploy applications (aka apps) on. Management of these systems is deployment, debugging, and monitoring of apps and creation and monitoring of database assets.

A good management system goes beyond the basics with tooling that takes into account the usage patterns. This helps to improve the actual architecture and applications themselves by giving better knowledge and power to the developers. The tooling can do this by taking advantage of the inherent structure of the services in the system. For example, my current system heavily relies on stream-based processing with Kafka. Thus, management tooling should revolve around the tree-like structure of streaming systems, with an emphasis on finding and managing relations between apps and streams. Previously, I worked on a large SaaS deployment that had a lot of publically accessible applications, with a single gateway; good management tooling would help to understand the gateway configuration of those public apps.

I've gone back and forth between GUI and CLI. A good CLI is a developer's best friend, but it makes higher-level applications harder to implement. GUIs these days are going to be web-based, where fancy libraries can be easily used, but scripting a GUI is a sisyphean task. I really like the Kubernetes approach here: excellent REST API with a GUI and CLI. The CLI can do what it does best: deployment, provisioning, and debugging. The GUI can focus on monitoring, simple deployments, and higher-level inspection.

As has been previously published, my team uses [pheidippides](http://activisiongamescience.github.io/2016/05/26/Pheidippides-part-1/) to deploy and configure docker containers to Marathon and other container orchestrators. This tech is very cool with its heirarchical configuration system and multiple deployment frameworks, but using it requires updates to Zookeeper, deployment locally or from Jenkins, and monitoring from Marathon (and possibly Mesos). To create the kafka topics requires Kafka Manager. It shouldn't take 5 apps to deploy and monitor an app.

This is why I'm creating **archon**, a management system for pheidippides [1]. I aim to bring together the core technologies (ZK, Marathon/Mesos, Kafka/Kafka Connect, Pheidippides) into a single REST API. Once this is complete, creation of a GUI that combines Marathon, ZKUI, Kafka Command Center and Kafka Manager will be relatively easy. But its the cross-system connections that really interest me, such as modeling systems as graphs and creating pipeline diagrams of how data flows through the system.

Eventually, we plan to open source archon with pheidippides, providing developers everywhere with a complete management system for multi-orchestration clusters.

[1] When [Pheidippides](https://en.wikipedia.org/wiki/Pheidippides) ran to Athens, he went to tell the Archons about the victory in battle at Marathon.
