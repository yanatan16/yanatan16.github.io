---
layout: post
categories: development code
title: Diagonal Lines in Sass
date: Sun May 26 2013 12:43:00 GMT-0600 (MDT)
redirect_from: /post/51408871092

# Old tumblr stuff
id: 51408871092
link: http://joneisen.tumblr.com/post/51408871092/diagonal-lines-in-sass
slug: diagonal-lines-in-sass
publish: 2013-05-026
tags: css3, transform, sass
---


While working on a new immersive experience for [underarmour.com](http://www.underarmour.com), we were given a comp that included some diagonal lines on it. These could always be created in background images, but [Ken](https://github.com/kjvalencik) and I thought it cooler to create them in css. We recently made the switch to [Sass](http://sass-lang.org) as our preprocessor library, so Ken and I (mostly Ken) created a Sass partial to create diagonal lines. A demo of the partial is over at [bl.ocks.org](http://bl.ocks.org/yanatan16/5653535/8ace84a61be6ba035cfd5b3f097b6093e633de95) and the raw code is available via a [gist](https://gist.github.com/yanatan16/5653535)

We’d like the interface to the mixin to be via start and stop positions, like so:

    hr.line {
        @include diagonal-line($x0, $y0, $x1, $y1);
    }

To calculate the necessary angles, we’ll need some extra functions to be available in Sass. Luckily, this can be done with ruby. Here’s `math.rb`

    # math.rb
    require 'sass'

    module Sass::Script::Functions
      def atan2(x, y)
         Sass::Script::Parser.parse(Math.atan2(y.value.to_f, x.value.to_f).to_s, 0, 0)
      end
      def sqrt(x)
        Sass::Script::Parser.parse(Math.sqrt(x.value.to_f).to_s, 0, 0)
      end

      declare :atan2, :args =&gt; [:float, :float]
      declare :sqrt, :args =&gt; [:float]
    end

Now, if we start our Sass watcher, we can reference this file and use the functions provided in our Sass: `sass --watch path/to/sass:path/to/css -r ./math.rb`. Its now a matter of building the mixin:

    // Creates a line segment with start and end points
    @mixin diagonal-line($x0, $y0, $x1, $y1) {
      position: absolute;
      left: #{$x0}px;
      top: #{-$y0}px;
      margin-top: 0px; // Reset hr's default styles

      $x: $x1 - $x0;
      $y: $y1 - $y0;

      // This is just a cross-browser transform: rotate($deg) implementation
      @include transform-rotate(#{-1 * atan2($x, $y)});
      width: #{sqrt($x * $x + $y * $y)}px;
    }

And whala! We’ve done it. Check out the [demo](http://bl.ocks.org/yanatan16/5653535/8ace84a61be6ba035cfd5b3f097b6093e633de95) for the full code.

