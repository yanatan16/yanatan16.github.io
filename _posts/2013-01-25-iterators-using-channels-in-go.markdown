---
layout: post
categories: programming
title: Iterators using channels in Go
date: Fri Jan 25 2013 15:51:51 GMT-0700 (MST)
redirect_from: /post/41471675675/

# Old tumblr stuff
id: 41471675675
link: http://joneisen.tumblr.com/post/41471675675/iterators-using-channels-in-go
slug: iterators-using-channels-in-go
publish: 2013-01-025
tags: go, golang, channels, iterators
---


Recently, while programming an RPC broker layer in [go](http://golang.org), I needed an iterator for a custom class I had created. In python, I would have just overridden `__next__()` (python3), and in java, I would have implemeted `Iterable`, but go, which tries to be very minimalist has no easy way to create an iterator.

Natively, the `range` built-in allows for easy iteration of slices, arrays, maps, and channels like so:

    for value := range mychannel {
      // do something
    }

So to give my class an iterator, I used channels! For this example, consider `Array` to be type I need to iterate over and `Value` to be the types that come out of the iterator. Heres our type definition and use case

    type Iterator struct {
      C chan Value
      closer chan bool
    }

    for v := range array.Iter().C {
      // do something
    }

And here’s the `Iter()` function definition.

    type Array []Value // In practice this is more complicated

    func (self Array) Iter() *Iterator {
      c := make(chan Value)
      closer := make(chan bool)
      iter := &Iterator{c, closer}

      // Spew out the iterator in a goroutine
      go func() {
        for _, v := range self {
          select {
            case c <- v:
            case <- closer:
              close(c)
              return
          }
        }
        close(c)
        close(closer)
      }()

      return iter
    }

Cool! Now whenever, I call `array.Iter()`, I’ll get a channel that will give me all the values in order. In practice, you wouldn’t do this with a type that maps to a slice, but something more complicated which couldn’t be used with the range built-in by itself.

Theres only one problem with this implementation. What happens if we break off the list? We can’t have goroutines and channels sitting unused. So we’ve already implemented the necessary stuff for the channel `closer` in `Iter()`, now we need only a `Break()` function (and a use case):

    func (i *Iterator) Break() {
      select {
        case _, ok := <- i.closer:
          // closer has been closed
        default:
          // closer is still open
          i.closer <- true
      }
    }

    iter := array.Iter()
    for v := range iter.C {
      // do something
      if true {
        iter.Break()
        break
      }
    }

This implementation shows how channels can be used to create iterators over any type in Go with minimal overhead and while keeping abstractions in place. For a working demo, checkout [this example on play.golang.org](http://play.golang.org/p/NIdDOIDzPU)
