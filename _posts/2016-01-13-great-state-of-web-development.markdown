---
layout: post
categories: programming
title: The Great State of Web Development
date: 2016-01-13 12:00:00
---

For everyone who just read [the Sad State of Web Development](https://medium.com/@wob/the-sad-state-of-web-development-1603a861d29f), I disagree.

<!--break-->

2015 was a great year for web development. We can create bigger and better web applications than ever before, with better code quality and faster page load times. The world wants Single Page Apps (SPAs), meaning we have to move huge amounts of logic from the server to the browser. We've been doing this for years, but in 2015, we've found better ways to build these large sprawling front end apps.

## React

As with years prior, almost everyone rewrote an app using the latest fad framework: [React](https://facebook.github.io/react/). Unlike the fads before it (Angular, Backbone.js, Ember.js, etc), React introduced three ideas which have changed web development radically. React may not last forever, but the ideas it brought us will stick around for a while.

React brought us the Virtual DOM. The virtual DOM allows the developer go hog wild with DOM manipulations, and the framework will compute the quickest possible difference to complete the changes. This means our code runs faster than ever before, even with more complex javascript processing. Many frameworks (not just React) have been produced or rewritten to use the virtual DOM: [Ember](http://slides.com/brandonkonkle/exploring-virtual-dom/#/44), [Elm](http://elm-lang.org/blog/blazing-fast-html), [Mercury](https://github.com/Raynos/mercury), etc.

React re-introduced an old idea from the PHP days: code and HTML templates together in the same file. This had gone out of style with MVC frameworks which espoused separating HTML templates and logic as far as possible. [JSX](https://facebook.github.io/react/docs/jsx-in-depth.html) may not survive more than a couple years, but the ideas will stick around. Coupling a component's logic with its DOM allows developers to reuse and share DOM components. This idea even has its own [W3C spec](http://w3c.github.io/webcomponents/spec/custom/). Many developers scoff at this idea, but after using it realize its benefits for code reuse and refactor.

People got their hands on React and started writing apps in it the same way they had done it forever, with object-oriented-inspired local state flying around everywhere. So Facebook also released their _philosophy_ of developing React, named the [Flux Architecture](https://facebook.github.io/flux/docs/overview.html). Rich Hickey has been talking about constraining state and instead focusing on data manipulation for years, but it wasn't until Facebook started talking about it to get all the UI programmers on board. This is probably React's greatest gift to the community, a true way to improve the efficiency of creating programs. The ideas from [Out of the Tar Pit](http://shaffner.us/cs/papers/tarpit.pdf) are clearly visible in Flux. Because its so popular, now almost any React shop is writing code _better_ than they were last year, by using functional data-flow concepts and moving away from OO design.

## Compile-to-JS

We've had compile-to-javascript languages for years now. In 2015 though, a few of them graduated to a new level.

[Babel](https://babeljs.io/) has become the de facto standard for writing javascript applications today. With more and more developers desiring ECMAScript 2015 features in their ES5-compatible browsers, Babel has provided that functionality for them. Not only that, but they've opened up the Babel core to plugin developers to allow people to write their own javascript transformers. Native support for JSX means that the React developer is probably also a Babel developer.

[Typescript](http://www.typescriptlang.org/) is probably Babel's closest competitor in popularity. It also brings ES2015 features through transpilation, but thats not its main idea. Typescript wants to introduce Java-style gradual typing to the javascript world. Personally, I believe the lack of types is a huge reason javascript is a terrible wasteland of low-quality code. Some people will argue with that, but no one can argue that eliminating a class of runtime errors entirely is a bad thing. The best part about gradual typing is that projects can write typescript as they grow and start to need better maintenance properties on their code.

[Clojurescript](https://github.com/clojure/clojurescript) has a growing community of functional programmers writing javascript. Clojurescript has tons of great features to make programming in it easier and faster. 2015 saw tons of development on this front from figwheel to self-compilation, but David Nolan [can say it better](http://swannodette.github.io/2015/12/23/year-in-review/).

[Elm](http://elm-lang.org/) is another functional compile-to-JS language, but instead of a lisp-inspired approach, Elm is ML-inspired, especially from Haskell and OCaml. However, Elm takes the approach of making it _easy_ to program in it, from top of the line error messages, to great tutorials, Elm and its maintainers are dedicated to a fantastic developer experience, as this [talk](https://www.youtube.com/watch?v=oYk8CKH7OhE) shows.

## Everything Else

Things are more complicated now than they have ever been. There are more plugins to download, more npm packages to comb over, more frameworks to consider, more languages to learn, more more more more more.

But complicated isn't necessarily bad. With these new transpilers, packages, frameworks, and languages, we can build bigger faster, become more maintainable, raise our code quality, and just make programming _easier_. Simple things are easier to understand, but don't provide the same power that a well-designed complex thing can.

Web development may be more complex now, but its greater than ever. I'd take that over any amount of excessive simplicity.
