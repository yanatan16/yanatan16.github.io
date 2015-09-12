---
layout: post
section: index
categories: development code
title: Haskell SPSA
date: Thu Jan 09 2014 20:05:51 GMT-0700 (MST)
redirect_from: /post/72830370364/

# Old tumblr stuff
id: 72830370364
link: http://joneisen.tumblr.com/post/72830370364/haskell-spsa
slug: haskell-spsa
publish: 2014-01-09
tags: haskell, spsa, optimization, hackage, golang
---


I’ve been getting into Haskell recently. Its a pretty theoretical language, which can be a barrier to entry. In fact, just writing your app/library’s types will probably make you flesh out the flow of your application. The type system is amazing though, and once you understand monads, you can do anything with a simple API.

I just uploaded my first package to [Hackage](http://hackage.haskell.org), [haskell-spsa](http://hackage.haskell.org/package/spsa-0.1.0.0). I haven’t fleshed out the documentation yet, so please forgive that transgression until I do. But like my [previously written library](http://blog.joneisen.me/post/52672521368), [golang-spsa](https://github.com/yanatan16/golang-spsa); haskell-spsa implements the optimzation algorithm [SPSA](http://jhuapl.com/SPSA). I wanted to walk a little bit through the code and my thought process.

<code data-gist-id="8346184" data-gist-file="Types.hs"></code>

The first thing to do when designing a haskell package is establish the types to be used. Nothing fancy here (no typeclasses or monads to define). Essentially, here, we are saying the prototype for a loss function and constraint function, as well as defining the parameters to actually run an iteration of SPSA. Note that the perturbation distribution and gain sequences (`ak` and `ck`) are infinite lists.

<code data-gist-id="8346184" data-gist-file="StandardAk.hs"></code>

Here, the implementation of the standard gain sequence for `ak` is a lazy map over an infinite sequence `[1..]`. Note that `\var -> func var` is an anonymous function definition.

<code data-gist-id="8346184" data-gist-file="Optimize.hs"></code>

Here, the meat of the package lies in this one function. First note the definition `optimize :: SPSA -> Int -> Vector Double -> Vector Double`. This implies that an `SPSA` and an `Int` will be use to optimize a `Vector Double`. This is exactly what is happening, where the `Int` refers to the number of iterations or rounds to optimize over.

Internally, we notice the `where` clause, where `constrainF` and `lossF` are just extracting parameters from the record syntax defined above. `opt` is a function defined locally within the `optimize`'s function scope which performs a single round of optimization. The top line of the function performs a `foldl` (also called a reduction or `reduce` in other languages) which accumulates a single value from a list, in this case a zip of three lists, the `ak`, `ck`, and `delta` (perturbation vector). The fold will take an input of the original estimated answer `t0` and output the final estimated answer (`tN` if you will). The actual definition of `opt` is taken almost directly from [golang-spsa](https://github.com/yanatan16/golang-spsa), so thats not too interesting in a haskell sense.

I’ve written this library 3 times now. As for the speed of the library, it does run pretty fast, but I can’t make direct comparisons to the other fast libaries out there. But one thing it maintains is a mathematical simplicity that few other languages can match. The Go version didn’t maintain any of the niceness that my [python version](https://gist.github.com/yanatan16/5420795) had, but the haskell version has speed and simplicity going for it, which is great.

