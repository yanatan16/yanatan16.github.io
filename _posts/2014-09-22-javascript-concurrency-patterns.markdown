---
layout: post
categories: development talks
date: Mon Sep 22 2014 11:21:44 GMT-0600 (MDT)
title: Javascript Concurrency Patterns
redirect_from: /post/98155451416/

# Old tumblr stuff
id: 98155451416
link: http://joneisen.tumblr.com/post/98155451416/javascript-concurrency-patterns
slug: javascript-concurrency-patterns
publish: 2014-09-022
tags: javascript, concurrency, patterns, queues, work queues, flow control, async, promises, events
---


*This post is a companion to a talk ([slides](http://talks.joneisen.me/presentation-javascript-concurrency-patterns/refactoru-9-23-2014.slide)) I am giving at RefactorU on Tuesday, September 23, 2014. It is cross-posted on [refactoru.com](http://blog.refactoru.com/javascript-concurrency-patterns/)*

I want to talk a bit about concurrency, and specifically, how does one do it in javascript. The short answer is: in like, a billion ways. There are, however, some patterns that emerge from the “best” attempts at concurrency in javascript. Those are the patterns that I’m talking about.

I should probably define concurrency ([Rob Pike does it better](https://talks.golang.org/2012/concurrency.slide#1)). Essentially, concurrency is multiple things happening at once. While you are waiting for an HTTP request to finish, you may also be adjusting styling on a web page. Or while waiting for three files at the same time, when they all finish, you would like to write a fourth file. This is the heart of concurrent programming; doing or waiting while other things might be happening at the same time. In addition these tasks might need to communicate, which you would like to do without shared memory (and the bugs associated).

In javascript, we are limited to a single thread of computation, which means processing can only be done in a serial fashion. Any concurrency then, is a product of waiting for external interactions such as button clicks, HTTP requests, and more. Thus javascript is designed as a concurrency-first language, where primitives for concurrency are available. Each `button.addEventListener('click', myfunc)` and `setTimeout(somefunc, 1000)` releases the thread of computation until such time as it should be called back. This allows more operations to occur in the mean time, and is therefore, concurrent.

### Flow Control

So let’s get into some basic patterns. To me, the most basic is flow control. Every other pattern uses flow control, and every programmer uses flow control every day. Flow control is essentially the act of controlling the execution of tasks in a parallel and series manner taking into account the dependencies between them. Naively, this is done with just callbacks calling other callbacks, which leads into *callback hell*, and then into insanity.

There are two main ways to stay sane whilst doing flow control: using a package to help with callbacks or using a package to wrap callbacks in promises. I suggest [async](http://npmjs.org/package/async) to control callbacks, and [q](http://npmjs.org/package/q) to wrap promises. My personal favorite is `async`, but I won’t hate you if you use promises. Here are two simple examples, but I implore you, as a javascript developer, to explore them deeply and get very used to using one of them daily, as it is very important moving forward with higher level patterns.

    async.parallel([task1, task2], callback) // parallel tasks
    async.series([task1, task2], callback) // series tasks


    Q.all([task1, task2]) // parallel promise
    task1.then(task2) // series promise

> Flow control is used all the time within higher level patterns to > simply accomplish the tasks of programming while staying away from > callback hell (and keeping sanity).

A special case of flow control which comes up a lot is asynchronous data mapping. Let’s see how `async` and promises handle this:

    async.map([some,list,of,objects], function (obj, callback) {
      doAsynchronousMappingTask(obj, callback)
    }, function (err, mappedObjects) { /* ... */ })


    Q.all([some,list,of,promised,objects]).then(function (objects) {
      return Q.all(objects.map(promisedMappingTask))
    })

### Events

Moving on to some higher level patterns, Lets talk about events and work queues. This is a survey of two very common patterns I see all over the place. I’ll give some links at the bottom for more reading on different patterns.

Events are a great way to allow multiple parts of your code (or third party code) to interact concurrently with each other. One part of the code can do `something.on('event', callback)`, then another can fire that event off at a later time `something.emit('event', data)`. This is super powerful in the browser where every DOM and `jQuery` object can fire its own events, and even intercept them. This allows intense concurrency. You can add callbacks for tons of different actions the user might take, and then get called back only when they happen by the browser itself. Another use is game engines, which have many actions that cause distant recomputations to occur. For instance if the players POV changes in a first person game, the scene must be recomputed. We can imagine a `reactor.emit('player-view', playerViewData)` and somewhere else a `reactor.on('player-view', recomputeScene)`. This allows two parts of the code to run concurrently and while communicating without interfering with each other.

> Events are a great pattern when you have repeating, but communicating
> concurrent actions.

Events Links:

-   [jQuery .on](http://api.jquery.com/on/)
-   [Demystifying Events in
    node.js](http://howtonode.org/demystifying-events-in-node)

### Work Queues

Work Queues are a simple data structure that has a single (required) operation: `push(work)`. Once work is pushed into the queue, it is worked on in some determined order. If the queue has infinite workers,
it will be worked on immediatedly. If it has a limited number of workers, it will be worked on when it is at the top of the queue and a worker is available. This structure can really improve the response time
of a system. Suppose whenever you get a save-data request, you have to
make 3 database calls in series. This can make the response time slow if
you waited for all three before responding. Instead, you can push into a
work queue and respond immediately, and when its being worked on, the queries will run. This situation makes the response time fast, without sacrificing the work to be done. In-memory queues, however, are prone to failure, so they aren’t for every situation. To improve it, you could store the queue in a more trustworthy source, such as an external database.

> Work queues are for situations where the response to a task isn’t
> needed by the requester, and often the task itself takes a long time.

Work Queue Links:

-   [Building one in Javascript](http://howtonode.org/tasks-and-prompts)
-   [async.queue](https://github.com/caolan/async#queue)

### More Patterns

I only talked about three of the most prominent patterns I use day-to-day. I suggest some further reading to be familiar with more of Javascript’s concurrency patterns:

-   [Node Streams](https://github.com/substack/stream-handbook)
-   [Express
    Middleware](https://blog.safaribooksonline.com/2014/03/10/express-js-middleware-demystified/)
-   [Using Redis as a distributed
    queue](https://github.com/Rafflecopter/node-relyq)
-   [ES6
    Generators](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/function*)
-   [CSP in Javascript (uses
    ES6)](http://jlongster.com/Taming-the-Asynchronous-Beast-with-CSP-in-JavaScript)
-   [Transducers.js](http://jlongster.com/Transducers.js--A-JavaScript-Library-for-Transformation-of-Data)
    (the new fad)


