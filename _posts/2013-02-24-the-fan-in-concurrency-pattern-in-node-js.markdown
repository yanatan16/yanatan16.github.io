---
layout: post
categories: development code
title: The fan-in concurrency pattern in node.js
date: Sun Feb 24 2013 21:46:00 GMT-0700 (MST)

# Old tumblr stuff
id: 43961435963
link: http://joneisen.tumblr.com/post/43961435963/the-fan-in-concurrency-pattern-in-node-js
slug: the-fan-in-concurrency-pattern-in-node-js
publish: 2013-02-024
tags: javascript, node.js, concurrency, fan-in, callbacks
---


I’ve been playing around in node.js lately. Many people have trouble
with the callback-only pragma and get caught in “callback soup”, which
is sometimes harder to debug than spaghetti code. I tend to abstract
things well, so while I was writing some recent node.js code, I found
myself constant repeating this pattern:

    function do2calls(options, callback) {
      var errs = [], cnt = 0;

      make_async_call_1(options, function (err) {
        if (err) errs.push(err);
        cnt += 1;
        if (cnt === 2) calback(errs.join('; '));
      });

      make_async_call_2(options, function (err) {
        if (err) errs.push(err);
        cnt += 1;
        if (cnt === 2) calback(errs.join('; '));
      });
    }

Not only am I repeating code here between async call one and two, but
ther is a common pattern here. This idea of n independent asynchronous
simultaneous calls being made and making a final callback once all of
those have returned is called the “fan-in” pattern. This gets really
hair when theres many more than two calls to make simultaneously. So I
wrote a generic way to perform this pattern:

    function fanin(n, callback) {
      var errs = [], objs = [], cnt = 0;

      return function (err, obj) {
        if (err) errs.push(err);
        objs.push(obj);
        cnt += 1;

        if (cnt === n) callback(errs.join('; '), objs);
      };
    }

Now, here’s how our `do2calls` code looks after we’ve abstracted the
fan-in pattern.

    function do2calls(options, callback) {
      var fan = fanin(2, callback);

      make_async_call_1(options, fan);
      make_async_call_2(options, fan);
    }

And here’s how one might save a (potentially long) list of mongoose
models:

    function mapsave(docs, callback) {
      var fan = fanin(docs.length, callback);
      _.each(docs, function (doc) {
        doc.save(fan);
      });
    }

Its relatively easy to extend this model for timeouts. You may also want
a version that doesn’t save the objects in case you don’t need the
return values. I’m sure there are other implementations of this pattern
out there, but I wasn’t able to find any. If there’s a good npm package
out there with concurrency patterns already implemented, I’d like to
hear about it. Rob Pike talks about this pattern in [this
video](http://blog.golang.org/2012/07/go-videos-from-google-io-2012.html)
about Go from Google I/O 2012.

