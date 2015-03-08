---
layout: post
categories: development code
title: Converting a callback-based function into an ES6 Generator
date: Thu Jan 02 2014 01:14:14 GMT-0700 (MST)
redirect_from: /post/71946205874

# Old tumblr stuff
id: 71946205874
link: http://joneisen.tumblr.com/post/71946205874/converting-a-callback-based-function-into-an-es6
slug: converting-a-callback-based-function-into-an-es6
publish: 2014-01-02
tags: javascript, ecmascript, es6, generators
---


In [node](http://nodejs.org), we have a lot of callback-based functions. In node 0.11, theres a big push for [ES6](https://wiki.mozilla.org/ES6_plans), which introduces a bunch of cool things to javascript, one of which is [generators](http://wiki.ecmascript.org/doku.php?id=harmony:generators). [Koa](http://koajs.com) is a new web framework from the creators of [express](http://expressjs.com) which uses the new generators as middleware. All the new generator stuff is great and you should really read more into it. It brings a level of concurrency that Go and python’s gevent (and others unmentioned) have to node and other javascript platforms.

Eventually, though, you’ll come across converting a callback-based function into a ES6 generator. This is pretty simple to fix though, we just need to create a promise which can be yielded to!

<code data-gist-id="8216252"></code>

