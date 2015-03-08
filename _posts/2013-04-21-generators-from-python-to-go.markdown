---
layout: post
categories: development code
title: Generators from Python to Go
date: Sun Apr 21 2013 17:53:00 GMT-0600 (MDT)

# Old tumblr stuff
id: 48568953293
link: http://joneisen.tumblr.com/post/48568953293/generators-from-python-to-go
slug: generators-from-python-to-go
publish: 2013-04-021
tags: iterators, python, go, golang, generators, channels, goroutines
---


Channels and goroutines in Go can be used just like
[generators](http://wiki.python.org/moin/Generators) in Python.

For instance, an generator in Python may be defined as like so:

    def myiter():
      for x in range(10):
        yield x ** 2

    for y in myiter():
      print(y)

In Go, we’d do something similar ([working
example](http://play.golang.org/p/bYNs8kvOkb)):

    func MyIter() chan float64 {
      c := make(chan float64)
      go func() {
        for i := 0; i &lt; 10; i++ {
          c &lt;- math.Pow(float64(i), 2)
        }
        close(c)
      }()
      return c
    }

    for y := range MyIter() {
      fmt.Println(y)
    }

If we were doing something more complicated with two-way communication
using generators, we’d have this pattern:

    def myiter2():
      x = yield
      while True:
        x = yield x**2

    mi2 = myiter2()
    mi2.send(None)
    for z in range(10):
      print(mi2.send(z))

And in Go, we could use one bidirectional channel, but I’m not a big
fan. I’ll use two uni-directional channels ([working
example](http://play.golang.org/p/pC-HFPkVmB)):

    func MyIter2() (in, out chan float64) {
      in, out = make(chan float64), make(chan float64)
      go func() {
        for x := range in {
          out &lt;- math.Pow(i, 2)
        }
        close(out)
      }()
      return in, out
    }

    in, out := MyIter2()
    for x := 0; x &lt; 10; x++ {
      in &lt;- float64(x)
      fmt.Println(&lt;- out)
    }

All four of these examples are simple, they just output the squares of
the numbers zero through 9, but they illustrate how a commonly used
pattern in Python can be easily adapted to Go.

*Note*: Please forgive the encoded symbols, I’m working on fixing it.

