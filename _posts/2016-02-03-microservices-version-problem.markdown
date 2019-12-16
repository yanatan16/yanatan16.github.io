---
title: "Microservices: The Version Problem"
layout: post
categories: programming
date: 2016-02-03 12:00:00
---

Microservices provide a great way to for organizations to create large complex systems easier. They make it easier to grok code. They force the developers to create composable, yet de-coupled parts of a system. They allow more developers to work on a large system with less communication overhead.

Despite all these positives, microservices are a tradeoff. There is a downside. Today, I'll discuss the biggest problem afflicting teams using microservices: **The Version Problem**.


<!--break-->

## The Version Problem

In a monolithic system, the version of the system is simply the version of the monolith repository, thanks to version control systems such as git.

In a polylithic system, the version of the system is the n-tuple of the versions of the repositories in question: `(A,B,C,D,...)`. This means that the total possible versions is equal to the permutation of all possible versions of each repository, which is a large number. However, most of these possible system versions are _invalid_.

> What are the _valid_ versions in a polylithic system?

---

Before I answer the question proposed, let's identify why this is an important question:

#### Example 1: Version Cloning

A service in production is producing a lot of errors. A developer, upon seeing this, starts debugging that service locally. Its passing all its tests and hasn't been deployed to in days. This developer then assumes the problem is with some other service (or set of services).

Now he/she must debug the full production system. So the developer must identify the version of each deployed component and get that running locally. If the developer gets even one of the repository versions wrong, the system is in the wrong state.

#### Example 2: Roll backs

A new feature requires simultaneous deployment of updates to two services (This is very common.). The team deploys the updates, and everything seems fine; developers go home. That night, the developer/operator on-call is alerted to errors coming out of the system. He/she makes the decision to roll back the latest deploy.

The operator must decide what state of the system to roll back to? Can he/she roll back one of the two updates? Must they be rolled back together? What about a possible third update that doesn't have to be rolled back?

#### Example 3: N-Tuples

Consider services A and B with versions `A1` and `B1`, and system version `(A1,B1)`. If we update both services with corresponding updates `A2` and `B2` that must be deployed together to work correctly, we now have three new possible versions: `(A2,B1)`, `(A1,B2)`, and `(A2,B2)`. But of those new versions, only `(A2,B2)` is valid.

Now, the team adds service C with version `C1`. A must be updated to `A3` to work with C. B now has an update, but it is independent of A and C. This is getting complicated quickly. Real systems have more services with many more versions, and it cannot be tracked [well] in one's head or in documentation.

---

## Monolithic Versioning

What these microservice-based systems have lost is monolithic versioning: a single place where valid versions of the system is tracked as if in a monolithic repository. Here are two ways to get monolithic versioning back.

#### Monolithic repository

Keep a monolithic repository for your polylithic architecture. That repository will have a single tree of versions which are tracked in the same way as a monolithic architecture. If the entire deployed system is on the same version, then its a valid deployment. This approach has its downsides, as its harder to identify whats a service and whats shared code, but it has upsides too. ([Etsy takes this view](https://medium.com/s-c-a-l-e/microservices-monoliths-and-laser-nail-guns-how-etsy-finds-the-right-focus-in-a-sea-of-cf718a92dc90#.w55xzvali).)

#### System Version repository

Create a new repository that holds a listing of the versions of all of the services and components in the system. Anytime this repository is updated, a new _valid system version_ is created.

The key to this approach is using this repository as a source of truth for your system. You can add configuration data, or information on how to deploy services. The point is that deployments and development environments should use this repository as key to creating and operating on the system.

For example, consider the [docker-compose configuration file](https://docs.docker.com/compose/). It contains a listing of each image version. If we checked in this file (or something like it, sans host-specific configuration) to a separate repository, it represents a monolithic versioning of the system. This can be used to create deployments and development environments at will.

## Conclusion

If you are having trouble figuring out valid system versions, current system versions, or historical system versions, create a monolithic versioning of your system. Track it, use it as source of truth, and keep it up to date. This will save your team time and money by preventing invalid versions from being deployed and saving developers time trying to figure out which versions are valid or not.

(_Note_: I am working on a [new side project](https://github.com/yanatan16/denvr) that is aimed to help solve this problem by creating a system version repository for development environments.)
