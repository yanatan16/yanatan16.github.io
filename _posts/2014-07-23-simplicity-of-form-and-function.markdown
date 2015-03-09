---
layout: post
categories: philosophy
date: Wed Jul 23 2014 15:03:00 GMT-0600 (MDT)
title: Simplicity of Form and Function
redirect_from: /post/92663247801/

# Old tumblr stuff
id: 92663247801
link: http://joneisen.tumblr.com/post/92663247801/simplicity-of-form-and-function
slug: simplicity-of-form-and-function
publish: 2014-07-023
tags: simplicity, building-systems, sicp, haskell, lisp
---


Simplicity is a desirable property when creating things for other people. It helps others grasp and understand the concepts involved. It drives my entire software development ideology. Here, I give a two types of simplicity lying at two ends of a spectrum.

We can define Simplicity of Form as simple construction. For example, a table has simplicity of form, due to it only having two parts and a clear construction pattern that anyone can follow. For a software example, think of assembly, which must only be translated to words (i.e. 32-bit or 64-bit binary strings) to be executed by the machine.

Simplicity of Function is a bit harder to nail down, but I think of it as easy to use or simplicity in usage. A bike or a car is simple to use, but complex to create (there are a ton of little parts). Python and Java are simple to use languages, relative to their complex construction.

This post stems from an argument I had with a friend about Haskell versus lisp. Let’s consider Haskell. Haskell is a language whose foundational abstractions are built on the mathematics of [Category Theory](http://en.wikipedia.org/wiki/Category_theory). The theory is simple relative to some mathematical topics. But, it is prohibitively complex for anyone outside of that world. One must learn an immense set of prerequisite mathematics to achieve true understanding. This makes it complex in its form or construction. But, simple code can render complex ideas on top of this construction.

The opposite language with respect to simplicity is lisp. The construction is so simple that a first year student can create an interpreter of it. (See [SICP](http://mitpress.mit.edu/sicp/) [chapter 4](http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-25.html#%_chap_4).) The beauty of the simplicity is in the idea that the developer writes in the language of the AST. The compiler or interpreter doesn’t have to translate from the syntax to the AST. But pure lisp provides few useful abstractions on its own (relative to Haskell). This is the dichotomy, one simplicity is at odds with the other.

In creating a complex system, there are many parts, some of which may be simple in form and some in function. This leads to the theorem that any sufficiently complex system can only be simple in form *or* function, but not both. Lisp’s simplicity allows you to build a system off of it but requires more abstractions on top. Haskell’s foundational abstractions, on the other hand, allows a concise representation of complex system.

These two paradigms lie on two ends of a simplicity spectrum. I don’t know which simplicity is better absolutely. I prefer simplicity of function because that is how we build abstractions up. But simplicity of form creates beautiful concepts.

Thanks to [JR](http://twitter.com/runningskull) for stimulating arguments and help editing on this post.

