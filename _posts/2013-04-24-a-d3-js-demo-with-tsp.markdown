---
layout: post
categories: development code
title: A d3.js demo with TSP
date: Wed Apr 24 2013 21:56:00 GMT-0600 (MDT)

# Old tumblr stuff
id: 48831028294
link: http://joneisen.tumblr.com/post/48831028294/a-d3-js-demo-with-tsp
slug: a-d3-js-demo-with-tsp
publish: 2013-04-024
tags: d3.js, tsp, simulated annealing, bmorejs, meetup
---


So I learned about a cool javascript library ([d3.js](http://d3js.org))
to do visualizations. Its very cool, check it out if you haven’t yet. I
wanted to try it out, so I made a Traveling Salesman Problem solver. You
can check out the [demo](http://yanatan16.github.io/d3-tsp-demo/) and
the [source code](http://github.com/yanatan16/d3-tsp-demo).

The code isn’t beautiful, but I wrote the whole thing in 3 hours after I
go home from the BmoreJS Meetup on d3.js. The algorithm it uses is a
basic version Simulated Annealing, straight from [Kirkpatrick et
al.](http://home.gwu.edu/~stroud/classics/KirkpatrickGelattVecchi83.pdf).

