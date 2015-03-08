---
layout: post
categories: development code pebble
title: Pebble Discs - deconstructed
date: Sat Feb 08 2014 08:58:00 GMT-0700 (MST)
redirect_from: /post/76005641249

# Old tumblr stuff
id: 76005641249
link: http://joneisen.tumblr.com/post/76005641249/pebble-discs-deconstructed
slug: pebble-discs-deconstructed
publish: 2014-02-08
tags: c, pebble, pebble-discs, watchface, walkthrough
---


With [Pebble 2.0](http://getpebble.com) coming out very soon, I can release a new watchface I’ve built: [Discs](https://github.com/yanatan16/pebble-discs). Discs is available on the app store, but you’ll have to search for it. Unfortunately, pebble has no web access to their app store (only on the apps) and no way to link into the app store AFAICT.

![Preview image at noon](https://raw.github.com/yanatan16/pebble-discs/master/resources/preview_noon.png)

![Preview image at 10:30](https://raw.github.com/yanatan16/pebble-discs/master/resources/preview_tenthirty.png)

As you can see above, this is a minimalistic watchface. It doesn’t have that many components; thus it should be a great candidate to deconstruct.

To make this watchface, we will create four discs, drawn on top of each other. The first and second are stationary in the center of the screen, while the third and fourth rotate about the center as time passes.

<code data-gist-id="8885664" data-gist-line="16-21,74-76,90-94"></code>

Here we declare our `Layer`s to hold our discs and set up their drawing order.

<code data-gist-id="8885664" data-gist-line="103,112-114,70-72"></code>

This is the “magic” function that creates a moving watchface effect. `tick_handler` runs every second and notifies the watch to redraw our hour and minute layers. Now all we must do is draw each disc.

<code data-gist-id="8885664" data-gist-line="40-44,50-58"></code>

Here we draw the face disc (center is similar) and hour disc (minute is similar). The face disc never moves, so we just draw it in the center. For the hour disc, we must calculate its angle using the current time and calculate its position based on that angle using a trigonometric helper function.

Boom. We’ve got a beautiful minimalistic watchface.. Everything else is boilerplate. Check out the [full code](https://github.com/yanatan16/pebble-discs/blob/master/src/pebble-discs.c)
and go make [your own watchface](http://developer.getpebble.com).

