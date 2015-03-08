---
layout: post
categories: development code
title: Rewriting haskell-spsa to be monadic
date: Wed Jan 22 2014 09:28:21 GMT-0700 (MST)
redirect_from: /post/74179055408

# Old tumblr stuff
id: 74179055408
link: http://joneisen.tumblr.com/post/74179055408/rewriting-haskell-spsa-to-be-monadic
slug: rewriting-haskell-spsa-to-be-monadic
publish: 2014-01-022
tags: haskell, spsa, state-monad
---


A couple weeks ago, I wrote the initial code for [haskell-spsa](https://github.com/yanatan16/haskell-spsa), which was a port of [golang-spsa](https://github.com/yanatan16/haskell-spsa). In my [first post on it](http://blog.joneisen.me/post/72830370364), I talked about the simplicity of the haskell implementation whilst also being fast. In my post at [make.rafflecopter.com](http://make.rafflecopter.com/side-project-jon-haskell.html), I talked about how porting a known package allowed me to learn how to build a haskell package the haskell way.

Last Sunday, I decided to take a crack at simplifying the API for creating and running SPSA into something easier to use and understand. I have been reading [Real World Haskell](http://book.realworldhaskell.org/) (a book for which I cannot give enough praise), and I figured I could use some apply some of my knowledge to this task.

Let’s take a look at the old API for creating an SPSA object.

<code data-gist-id="8560908" data-gist-file="old_create.hs"></code>

I wrote this code, and I can’t tell you exactly what its doing without digging through the source. Theres magic numbers being thrown everywhere with no regard! Now, lets see the new API:

<code data-gist-id="8560908" data-gist-file="new_create.hs"></code>

Here we have what appears to be a much more *imperative* API. But, even though it is more verbose, it is more self-explanatory as to what each line is doing. We are constructing an SPSA configuration from the ground up, setting the loss function, stop criteria, perturbation vector, and tuning the gain sequences (`a` and `c` are the primary tunable parameters). Better yet, theres no IO monad buried deep down (but you’ll need to pass in a random seed). How is this implemented, a question you might be asking.

<code data-gist-id="8560908" data-gist-file="impl.hs"></code>

By using the State monad, we can apply incremental updates to the implicit state of an `SPSA` data type as we construct it. That way, we can build an SPSA configuration in many different complex and complicated ways and keep a sane API. Now, let’s see how this has affected the internals.

<code data-gist-id="8560908" data-gist-file="optimize.hs"></code>

We can see in that piece of code that the core optimization functions are more easily taken in without a bunch of `where` clauses. `runSPSA'` is a simple tail-recursive function which runs a `singleIteration` until `checkStop t t'` returns true. All of this is done without explicitly passing around an `SPSA` object thanks to the `State` monad.

<code data-gist-id="8560908" data-gist-file="runspsa.hs"></code>

Finally, we have the exported `StateSPSA` runner, which runs the SPSA instance with a given guess and returns the final guess.

For more details, check out the [github](https://github.com/yanatan16/haskell-spsa) and the [examples](https://github.com/yanatan16/haskell-spsa/tree/master/example), or download it from [hackage](http://hackage.haskell.org/package/spsa) and start hacking!

