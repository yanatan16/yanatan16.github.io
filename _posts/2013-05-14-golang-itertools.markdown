---
layout: post
categories: programming
title: Golang Itertools
date: Tue May 14 2013 08:02:01 GMT-0600 (MDT)
redirect_from: /post/50419771247/

# Old tumblr stuff
id: 50419771247
link: http://joneisen.tumblr.com/post/50419771247/golang-itertools
slug: golang-itertools
publish: 2013-05-014
tags: python, iterators, generators, golang, itertools
---


# Golang itertools

I was going to do something productive today, but I got sidetracked into creating a golang library that translated python’s `itertools`. Its more of a thought exercise than anything else at this point, but it has a full test suite and is pretty easy to use. You can check it out on [github](http://github.com/yanatan16/itertools) or the [documentation](http://godoc.org/github.com/yanatan16/itertools).

Here’s a few examples of what you can do:

    // Sum of all squares who end in 3 up to 10000
    summer := func (a, b interface{}) interface{} {
      return a.(int) + b.(int)
    }
    squarer := func (a interface{}) interface{} {
      return int(math.Pow(a.(float64), 2))
    }
    mod3er := func (a interface{}) interface{} {
      return a.(int) % 10 == 3
    }
    Reduce(Filter(mod3er, Map(squarer, Count(1))), summer, 0)

    // Get a list of letter counts in words of a string
    Map(func(a interface{}) interface{} {
      return len(a.(string))
    }, New(strings.Split(someString, " ", -1)))

    // Use a complicated struct as the value
    type MyStruct struct {
      I int
      S string
    }
    val a, b, c MyStruct
    iter := New(a, b, c)
    return Filter(some_predicate, iter)

    // Ordered Dict iterator
    type OrderedDict struct {
      Order []string
      Dict map[string]MyType
    }

    func (od *OrderedDict) Iter() itertools.Iter {
      return Map(func(str interface{}) interface{} {
        return od[str.(string)]
      }, New(od.Order...))
    }
