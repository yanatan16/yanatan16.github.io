---
layout: post
categories: programming
title: Golang and default values
date: Sun Jun 23 2013 13:39:00 GMT-0600 (MDT)
redirect_from: /post/53695478114/

# Old tumblr stuff
id: 53695478114
link: http://joneisen.tumblr.com/post/53695478114/golang-and-default-values
slug: golang-and-default-values
publish: 2013-06-023
tags: golang, default-values, variadic-arguments
---


Go does not allow default values in function prototypes or function overloading. The Go language specification is remarkably small, and is purposefully maintained that way to keep the parser simple. Default values would add complexity to function definition syntax.

So how does one implement default values in real code? We have four options: forced user selection of default values, a single optional parameter, using a config struct, or full variadic argument parsing. Let’s imagine we’re making a function that concatenates a string and an integer.

Option 1: The caller chooses to use default values

    // Both parameters are optional, use empty string for default value
    func Concat1(a string, b int) string {
      if a == "" {
        a = "default-a"
      }
      if b == 0 {
        b = 5
      }

      return fmt.Sprintf("%s%d", a, b)
    }

Option 2: A single optional parameter at the end

    // a is required, b is optional.
    // Only the first value in b_optional will be used.
    func Concat2(a string, b_optional ...int) string {
      b := 5
      if len(b_optional) > 0 {
        b = b_optional[0]
      }

      return fmt.Sprintf("%s%d", a, b)
    }

Option 3: A config struct

    // A declarative default value syntax
    // Empty values will be replaced with defaults
    type Parameters struct {
      A string `default:"default-a"` // this only works with strings
      B string // default is 5
    }

    func Concat3(prm Parameters) string {
      typ := reflect.TypeOf(prm)

      if prm.A == "" {
        f, _ := typ.FieldByName("A")
        prm.A = f.Tag.Get("default")
      }

      if prm.B == 0 {
        prm.B = 5
      }

      return fmt.Sprintf("%s%d", prm.A, prm.B)
    }

Option 4: Full variadic argument parsing (javascript style)

    func Concat4(args ...interface{}) string {
      a := "default-a"
      b := 5

      for _, arg := range args {
        switch t := arg.(type) {
          case string:
            a = t
          case int:
            b = t
          default:
            panic("Unknown argument")
        }
      }

      return fmt.Sprintf("%s%d", a, b)
    }

[Full Demo](http://play.golang.org/p/VVA4i6l1W4)

For API stability reasons, I suggest Option 3 or 4, as those will not break code relying on your API. Furthermore, Options 1, 2, and 3 are the best documented in code. Its for that reason that I use Option 3 (Config structs) the most in my code.

Update: Thanks to [@davecheney](https://twitter.com/davecheney) for suggesting the type switch in the Option 4. Its much cleaner.
