---
layout: post
categories: development code
title: Follow up to the fan-in concurrency pattern
date: Tue Feb 26 2013 08:11:43 GMT-0700 (MST)

# Old tumblr stuff
id: 44063909418
link: http://joneisen.tumblr.com/post/44063909418/follow-up-to-the-fan-in-concurrency-pattern
slug: follow-up-to-the-fan-in-concurrency-pattern
publish: 2013-02-026
tags: concurrency, node.js, node, fanin
---


I got some good responses to my last post on the [fan-in concurrency
pattern in node.js](http://joneisen.me/post/43961435963), so I decided
to make my first npm module with it. To wit, I introduce
[fanin](http://npmjs.org/package/fanin/1.0.5).

I also checked out a few existing modules:
[after](https://npmjs.org/package/after),
[async](https://npmjs.org/package/async). Both of these have similar
functionality, but I happen to like my syntax better [read: bias].

