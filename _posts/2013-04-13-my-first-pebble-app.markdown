---
layout: post
section: index
categories: development code pebble
title: My First Pebble App
date: Sat Apr 13 2013 12:43:39 GMT-0600 (MDT)
redirect_from: /post/47883135336/

# Old tumblr stuff
id: 47883135336
link: http://joneisen.tumblr.com/post/47883135336/my-first-pebble-app
slug: my-first-pebble-app
publish: 2013-04-013
tags: pebble, c, pebble-binary
---


So I just received my [pebble](http://getpebble.com) watch. And of course the first thing I do is create a new watchface for it! I made a [binary watchface](http://yanatan16.github.io/pebble-binary) for the pebble watch. Its a bit esoteric, but it was pretty cool making it. There’s a screenshot at the bottom of this post.

The pebble SDK is in its infancy, but still pretty functional for the basic stuff. Its completely in C (which you’d expect from an ARM micro-device). The [documentation](http://developer.getpebble.com) is good though, and fully describes everything you’d need. I was a little worried I’d brick the device on a null memory access, but it was pretty resilient to my novice-ness (I haven’t written C since college). The best is the fact that all the current watchfaces, as well as some 10-15 demo apps. One of my trip-ups was the fact that my watch was at an old firmware version, which it didn’t tell me that and my apps were just getting dropped with silent failures. Once I figured out to update, it was smooth sailing to take the basic app and customize it. Overall, it took me about 3-4 hours to get set up and create the app.

I think I’ll see if I can create something with more functionality and usefulness next time, but this was a fun first step. [Check it out!](http://yanatan16.github.io/pebble-binary)

![](http://yanatan16.github.io/pebble-binary/img/binary_screenshot.jpg "Pebble-Binary Screenshot")

