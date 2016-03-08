---
title: "Microservices: Documenting Inter-Service APIs"
layout: post
section: index
date: 2016-03-07 18:00:00
categories: architecture
---

_This is the second in a series on the perils of microservices. Check out [Microservices: The Version Problem](/2016/02/03/microservice-version-problem.html) too._

> Microservice _A_ needs to talk to microservice _B_. _B_ provides an API of some sort. _A_ uses the API to contact _B_.

These microservices have entered into an API contract. Since _A_ relies on _B_, anytime _B_ changes its API, A must be notified and updated. This contractual dependency is usually **undocumented** not statically verified. That means that in any real system, the contract can and will be broken, especially as the number of contracts in a system increases at a large rate.

<!--break-->

TLDR; Use schema libraries to get easy-to-use code-as-documentation and static verification of your interservice APIs.

### Public APIs

Let's take a look at public APIs, such as [Stripe](https://stripe.com/docs/api)'s:

- It is extremely well documented.
- It has a well-designed REST-based API.
- It has client libraries that can be included in your code to statically verify the API usage.
- It **never** breaks a contract because you can use [any API version back to 2011](https://stripe.com/docs/upgrades#api-changelog).

This is the huge amount of work that Stripe has put in to ensure their API never breaks its contract, and your use of their API will be as correct as possible.

### Inter-service APIs

Most internal APIs between microservices are not so lucky. In the organizations I've been in, you're lucky to find old documentation for an API in a README. Changes are rarely documented. Most of the time, theres no way to verify one service is calling the other one correctly. Furthermore, when multiple authors create multiple APIs for a system, they tend to have core differences in their operation, which hurts the system's consistency.

### RPC

Back in the day (i.e. 3 years ago), everyone was into Remote Procedure Call (RPC). [Protobufs](https://github.com/google/protobuf) was all the rage, but [Thrift](https://thrift.apache.org/) came with an RPC implementation by default. These systems required that you document your APIs, and then RPC code could be generated. This code made it seem that a local function call was local, when in fact, it was remote.

Everyone now agrees that hiding the behavior of your functions is a bad idea, but I think there is something lost by completely abandoning the practice of documenting the APIs. The code-as-documentation and validation factor cannot be undersold.

## Schema

I believe the solution to these problems, strongly influenced by RPC, is API call schema validation. By documenting your APIs with schema, you get many benefits that Public APIs enjoy.:

- Schema helps document your inter-service APIs, and acts as code-as-documentation
- By keeping all the schema in one place, you can compare APIs to make them more consistent, and perhaps better designed.
- Schema gives you static analysis tools to ensure that API contracts aren't broken (as long as the [Version Problem](/2016/02/03/microservice-version-problem.html) doesn't bite you)

Take each interservice API and document its types and actions. This schema should live either in your monolithic repository or in a new repository if using [polyrepo](https://twitter.com/jm_eisen/status/707007124283518976) organization. Include and use it for validation and documentation of both the API producer and consumer. It could be [JSON schema](http://json-schema.org/), [Swagger](http://swagger.io/), Clojure's [Prismatic Schema library](https://github.com/plumatic/schema), or any other schema validation library.
