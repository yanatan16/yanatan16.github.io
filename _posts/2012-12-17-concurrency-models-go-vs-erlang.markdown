--- layout: post
categories: development popular
title: "Concurrency Models: Go vs Erlang"
date: Mon Dec 17 2012 18:06:00 GMT-0700 (MST)

# Old tumblr stuff
id: 38188396218
link: http://joneisen.tumblr.com/post/38188396218/concurrency-models-go-vs-erlang
slug: concurrency-models-go-vs-erlang
publish: 2012-12-017
tags: golang, erlang, concurrency, OTP
---


I like to think that I understand Go’s concurrency model pretty well. Last week, I learned Erlang (thanks to [Learn You Some Erlang](http://learnyousomeerlang.com/)) and created my first Erlang application (a fully-asynchronous RPC implementation with [Protobufs](http://code.google.com/protobuf) and [zeromq](http://zeromq.org)). Despite the fundamental differences between the languages, Go being imperative and Erlang being impure functional, there are underlying concurrency models that appear very similar.

On the surface Go and Erlang have very similar concurrency models. Both allow easy spin up of “lightweight threads”, known as processes in Erlang and goroutines in Go. Essentially these are threads that are managed by the underlying runtime and not the OS. This layer of indirection provides significant value, as it allows the applications to spin up threads without worrying about the heavy weight (memory, swap, cpu, etc), as well as making it really easy.

In Go: `go doSomething()`. Erlang: `spawn(fun do_something/0)`.

Both Go and Erlang provide message passing patterns. These are the core of concurrency, because there is no need to use shared memory (the root of all evil)! But they do it differently. Go provides channels, which can be thought of as in-memory sockets. Channels allow you to do many advanced patterns that I won’t get into here, so check them out if your interested. Channels have types and you can pass objects of those types through the channels between goroutines. Erlang processes have individual mailboxes which can receive messages of any type.

    //Go
    c := make(chan string, 1)
    go func () { fmt.Println("Got %s from the channel", &lt;- c) }()
    c &lt;- "foobar"

    //Erlang
    Pid = spawn(fun() -&gt;
            receive Val -&gt; io:format("Got %s from the mailbox", [Val])
            end
        end),
    Pid ! "foobar".

Where Go and Erlang have the biggest differences is error handling. That probably wasn’t what you expected to read, but the two languages couldn’t have more different philosophies on errors. In Go code, you make your own errors and you handle them manually. The language (originally) has no way to immediately raise an error like practically every other language. Since then, they have added a `panic` function, but it is not meant to be used predominantly in production code. This is a common idiomatic pattern in Go:

    result, err := doSomething()
    if err != nil {
        // log it or return or ignore
    }

Erlang is one of those exception languages. For all intents and purposes, it works similar to Java and Python. In Erlang, it is idiomatic to let your functions fail unless you specifically want to ignore errors. Here’s the three ways you can raise exceptions in Erlang.

    throw(this_is_a_throw_exception),
    error(this_is_an_error_exception),
    exit(i_bet_you_can_guess_what_this_does).

In a vacuum, both schemes are valid, and I don’t really prefer either over the other. The issue comes up in concurrency. In go, the author handles all the errors manually, so he or she knows exactly which goroutines might fail and creates layers of indirection to handle them. Erlang, on the other hand allows, and even promotes as idiomatic, processes to exit due to error/throw/exit conditions. This creates some problems in long-term fail-safe programs. For instance, what if there are a pair of processes that work in unison and one of them dies?

Erlang manages this using a generic set of servers and supervisor implementations (known as the [OTP](http://www.erlang.org/doc/design_principles/gen_server_concepts.html)). These generic implementations save the author from writing the boilerplate code of their long-running processes over an over again (and hence making mistakes). In writing a generic server process that can handle requests and hold state, you have to implement 7 different callbacks. Then you have to implement supervisors that monitor the worker processes to restart them as appropriate if they fail. These supervisors give the author a good measure of assurance that the process group will not die and stay dead, but it is still more complicated than a simple implementation.

In Go, you handle errors, and hence you manage everything about your goroutines and in-process servers. In Erlang, the language handles errors, and you have to manage the consequences of those errors. The Go implementation is more straightforward, while the Erlang implementation involves more callbacks and indirection.

In addition to the author’s experience, there are underlying differences in the concurrency implementations. Go is built to run on multicore processors and uses a shared-memory model. Erlang is built to run on multiple computers and does not allow shared-memory.

The concurrency models seem similar, but are in fact very different due to the error handling of each language. You can choose the one that fits best for your project.

**Update**: Since I wrote this article, I’ve had a lot of talks with some very knowledgeable Erlang programmers. My experience with Erlang is pretty minimal, and the opinions I’ve expressed were more from my experience creating my first Erlang programs, not the experience of 10 years working with idiomatic Erlang. That said, I should clear up a few things. There are a couple main other differences between the languages’ concurrency models:

-   Erlang’s concurrency model uses “processes” and does not share memory, which Go’s goroutines do.
-   Erlang’s scheduler is preemptive, which is a goal of Go’s but not the current state.

As for Erlang’s exception model, it is safer than Go’s because of OTP. The model is still more formal than Go’s, but OTP has made it safer because of monitor/restart semantics. From talking with some more knowlegeable Erlang people, its clear to me that error/exit/throw and try/catch syntax is rarely used, and the more appropriate “error as a value” is used idiomatically. This is the same as is forced in Go (since Go has no throw except for panic, but don’t use that). Thus perhaps the two models are not as dissimilar as I first suggested. The informality of the model in Go is still attractive, but the safety guarantees are better in Erlang.

