---
layout: post
section: index
categories: philosophy development
title: Why I like Go
date: Sun Jun 24 2012 21:16:00 GMT-0600 (MDT)
redirect_from: /post/25828323094/

# Old tumblr stuff
id: 25828323094
link: http://joneisen.tumblr.com/post/25828323094/why-i-like-go
slug: why-i-like-go
publish: 2012-06-024
tags: golang, language
---


Languages are tools to describe systems. Each has its pros and cons. C++ is good at making fast executing systems. Python and ruby make systems eaiser to quickly prototype. Ada makes safe systems attainable. When I looked at Go initially, I didn’t really see its benefit. I couldn’t answer the question: What systems does Go describe better than/as good as other languages? It turns out, its really good at being an all-around competitor, it can script, be expressive, be concurrent and be modern.

Go can be a script. Its quick compiler makes using it as a scripting language possible. Using the `go run mycmd.go`, you can quickly compile and run a script in as quick a time as python or bash. The best thing about it is that since its compiled, it’ll run much faster than a typical interpreted language ([Go vs Interpreted](http://shootout.alioth.debian.org/u32/which-programming-languages-are-fastest.php?calc=chart&go=on&yarv=on&python3=on)).

Go’s expressiveness saves SLOC. It’s typing system allows you to apply functions to any local type (classes are just structs with functions), so your custom error can really just be a string, not a class that just contains one string. Getters and setters aren’t required, because fields are automatically exported or not exported by whether the first letter of the field name is capitalized. The interface system makes polymorphism a breeze (like Java). If you’re declaring a variable and instantiating it, you don’t have to write the type out, just use “:=”; go will automatically figure out what type it should be. My favorite expressive feature is the package import system and naming conventions (see below). By having the imported package name be required to be typed out, it can be implicitly used in the naming of exported static functions.

    import "net/http"
    //[...]
    http.Handle("/stuff", http.Handler(myHandler));

Go is great at concurrency. The concurrency model of Go involves two main features: goroutines and channels. Goroutines are like really lightweight threads; nothing groundbreaking here. But they are really easy to use! Here, I’ll call a goroutine right now.

    go func() {
      blog.WritePost('Why I like Go', content)
    }()

This will spin off an asynchronous goroutine to write a blog post. Ok so a couple things to note about this call. First, the call to make a goroutine, just the word `go`. Second, Go has lambda functions, as the function was created on the fly, in a closure (It could just as easily be a regular function call.). Also, don’t feel bad about spinning off a bunch of these, since they are so lightweight, the system can handle thousands of goroutines running and will allocate threads as necessary. Thirdly, unlike Java, Go is function-based, not class-based, so you don’t have to write a class just to call a single function. In fact, here is the same call in Java:

    Thread t = new Thread(new Runnable() {
      void run() {
        blog.writePost("Why I like Go", content);
      }
    });

Less confusion in the syntax, and shorter to write. The goroutine syntax has the advantage of abstracting exactly what kind of asynchronous architecture the compiler actually chooses to use.

Now about channels, the other great concurrency model. Channels make mutex’s unnecessary in most cases by encouraging asynchronous goroutine communication and data-passing (and if you must, they make them easier to implement). Channels are like in-memory sockets. You can give them buffers and types. They can have values sent on them (blocking and non-blocking), and they can be received on (blocking and non-blocking) or both Channels act like regular variables, so they can be passed around in closures and into multiple goroutines to allow communication. There are tons of great uses for channels that I didn’t think of initially. One of my favorite uses of channels is this:

    errs := make(chan error, 0)
    go StartServer(errs)
    for err = range errs {
      //log err however I want
    }

A channel of errors! Never have I seen such a succinct abstraction of how errors are passed out to the master program to be logged as desired. No more dealing with choosing and configuring an slf4j implementation because the web server you are using chose to log using it. Now you can send log messages back to the main function in a succinct and, dare I say beautiful, way.

Finally, Go is modern. It has maps (dicts) built-in. It handles UTF-8 natively. It is garbage collected ([Don’t worry about speed](http://shootout.alioth.debian.org/u32/which-programming-languages-are-fastest.php?calc=chart&gpp=on&java=on&go=on&hipe=on)). It comes with a webserver built-in. It handles package retrieval. It formats source files for you. It has a test framework built-in. It has iterators built-in (see the range command). It can do formatted and default-formatted output (like python).

So Go is great for web servers (quick prototyping, easy concurrency), Go can be reused for command line easily, and its just fun! If you’re tempted, [try Go!](http://golang.org)

