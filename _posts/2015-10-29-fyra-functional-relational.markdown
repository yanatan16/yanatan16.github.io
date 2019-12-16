---
layout: post
categories: programming
title:  fyra and Functional Relational Programming
date:   2015-10-29 12:00:00
---

Introducing my latest OSS side project, [fyra](https://github.com/yanatan16/fyra), an experimental implementation of Functional Relational Programming, as described in the paper _[Out of the Tar Pit](http://shaffner.us/cs/papers/tarpit.pdf)_.

<!--break-->

### Functional Relational Programming

The authors of the paper and I call Functional Relational Programming FRP, but it is _different_ from the popular programming style Functional Reactive Programming.

<!--explain FRP and paper's views-->
FRP is a style of declarative programming that mixes functional and logical styles. It's aim is to reduce the amount of _accidental complexity_ in software projects. Accidental complexity is defined in the paper as complexity that the users of an application do not care about, only the authors of that application. Generally, this is referring to state that isn't persisted, cache strategies, performance improvements, and boilerplate code necessary given technology choices.

FRP aims to reduce that complexity by establishing four things: a relational model data store (actual data store is up to infrastructure choice), a way for _observers_ to update the UI or send messages when the data they care about changes, a way to update the data (called _feeders_), and ways to declaratively specify performance hints to the underlying infrastructure.

The authors intention is to specify a style of programming, but leave the underlying implementation of this language up in the air. In order to fully understand the intention of the authors, I decided to try my hand at creating an infrastructure for FRP. This is what I've been working on for a few weeks.

### fyra

<!--Show some code in fyra-->
[fyra](https://github.com/yanatan16/fyra) is an FRP DSL in Clojure. It explicitly implements the relational algebra through functions like `project` and `summarize`, as opposed to installing a more SQL-like syntax. Currently, it has enough functionality to support the [example real estate application](https://github.com/yanatan16/fyra/tree/master/example/real_estate) given in the paper. It uses an in-memory database with custom-written relational implementation (this was fun to write).

<!--future of fyra: multiple implementations, cljs/reagent, datomic query style-->
As I work on fyra, I'd like to enable it to have two more implementations beyond the current simple in-memory datastore: SQL-backed in Clojure, and Reagent-compatible in Clojurescript. Then, from there, I can examine data sync requirements between the two. Additionally, fyra needs to implement performance hints like saving cached versions of views.

<!--Mention David Nolan's work on logic programming and Om Next-->
I am heavily inspired by [Om Next](https://github.com/omcljs/om/wiki/Quick-Start-%28om.next%29), where pieces of UI declare their data requirements in a relational logic, and data is requested from a Datomic-compatible backend. (David Nolan's other work is also [really cool](https://github.com/swannodette).)

### What have I learned

So far, I've learned a lot about what it takes to make a relational query engine. I'd like to continue to experiment with these implementations to make it better, and have a smaller, yet intuitive syntax.

I've also started appreciating the relational model. I already **love** decalarative notations on programming. By combining with the relational model, its possible to really have a fully functional system with declarative data requirements. Previously, a lot of my work with declarative data requirements was with an Object model, which doesn't provide the same abilities to declaratively select the variety of things that one might need. The relational model works better because its pluggable, a relation can be operated on by anything in the algebra, i.e. there are no special objects.

If you haven't yet, you should read _[Out of the Tar Pit](http://shaffner.us/cs/papers/tarpit.pdf)_. It is written by Ben Mosely and Peter Marks.
