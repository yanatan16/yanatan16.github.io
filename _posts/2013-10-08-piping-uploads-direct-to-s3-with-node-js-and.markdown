---
layout: post
categories: programming
title: Piping uploads direct to S3 with node.js and express
date: Tue Oct 08 2013 08:57:00 GMT-0600 (MDT)
redirect_from: /post/63468698622/

# Old tumblr stuff
id: 63468698622
link: http://joneisen.tumblr.com/post/63468698622/piping-uploads-direct-to-s3-with-node-js-and
slug: piping-uploads-direct-to-s3-with-node-js-and
publish: 2013-10-08
tags: node.js, express.js, connect, middleware, multipart, uploads, s3, streams2
---


UPDATE: I packed up this functionality into some middleware:
[multipart-pipe](https://github.com/yanatan16/multipart-pipe)

Recently, [express](http://expressjs.org) found a small vulnerability in
their body parsers where an attacker could DDOS an express app by
sending a bunch of uploaded files to the multipart parser, which creates
temporary files.

Here’s how you can setup express to pipe uploads direct to S3 without
ever writing to disk.

First we add the key piece of middleware:

    app.use(express.multipart({ defer: true }));

Make sure you do not have `app.use(express.bodyParser())` in your
middleware chain because this causes a redundant (and wrong) multipart
parser.

Here’s the core piece of code:

<code data-gist-id="6886035" data-gist-line="15-30"></code>

The `req.form` object and its event `'part'` are created by the deferred
multipart middleware; each file will have a part and the data stream can
be piped directly to S3 using the streams2 from node 0.10+.

And whala! No temporary file vulnerability, and all uploads go directly
to S3!

Note: cross-blogged at
[make.rafflecopter.com](http://make.rafflecopter.com/pipe-uploads-to-s3.html)
