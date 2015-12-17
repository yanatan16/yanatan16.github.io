---
layout: post
section: index
categories: clojure
title: Core.async Helpers
---

I went to the [Boulder Clojurians][1] meetup tonight where we discussed `core.async`. One of the topics of discussion was helper functions that help you work with `core.async`. I've worked with it a few times in the past, and here are a few of the things I seem to do (almost) every time.

<!--break-->

## Callback to Async

Sometimes, you have a function that is asynchronous via a callback, such as with `http-kit.client`, or when working with `nodejs`. To convert these functions into channel-based operations can be tedious, so lets just use a function for it!

Imagine a function `(f a b callback)` where callback is an `(fn [value])`. Let's create a function (or macro) so we can do `(go (<! (cb->async f a b)))`

A first cut using a function:

<code data-gist-id="a4aac1fd35977fcaaecd" data-gist-file="core-async-helpers.clj" data-gist-line="4-8"></code>

This is a pretty nice tool for working with callback-based functions. But we can make it better! First, we can use `async/onto-chan` instead of `#(go (>! c %))`. Secondly, we can "inline" the call by using a macro.

Here's a revised implementation, this time for use with nodejs.

<code data-gist-id="a4aac1fd35977fcaaecd" data-gist-file="core-async-helpers.clj" data-gist-line="11-14"></code>

## Async as Promise

`core.async` provides a lot of functionality for comparatively little syntactical overhead. But it doesn't always provide helpers for all the use-cases. One case I seem to use a lot (especially in clojurescript) is promises. I like the flexibility of `core.async`, but I want more promise-like helpers.

Luckily, the library recently released `core.async/promise-chan`, which acts like a promise, containing only ever one value.

<code data-gist-id="a4aac1fd35977fcaaecd" data-gist-file="core-async-helpers.clj" data-gist-line="17-33"></code>

Astute observers will note that `promise-map` is the promise functor's fmap function, while `then` is the promise monad's bind function.

## Don't rewrite the wheel

There are so many goodies in the `core.async` library that you probably don't need to write a bunch of generic helper functions.

- For connecting tasks, checkout [pipe][2] and the [pipeline-*][3] family of functions.
- [mult][4] and [tap][5] help with stream processing while [pub][7] and [sub][8] do what you think they do.
- [split][6] is useful for splitting channels, such as errors from successful values.

[1]: http://www.meetup.com/Boulder-Clojurians/events/227340101/
[2]: http://clojure.github.io/core.async/#clojure.core.async/pipe
[3]: http://clojure.github.io/core.async/#clojure.core.async/pipeline
[4]: http://clojure.github.io/core.async/#clojure.core.async/mult
[5]: http://clojure.github.io/core.async/#clojure.core.async/tap
[6]: http://clojure.github.io/core.async/#clojure.core.async/split
[7]: http://clojure.github.io/core.async/#clojure.core.async/pub
[8]: http://clojure.github.io/core.async/#clojure.core.async/sub
