---
layout: post
categories: development code
title: pycodejam - A CodeJam solution runner for python
date: Sat Dec 22 2012 13:08:08 GMT-0700 (MST)
redirect_from: /post/38565060255

# Old tumblr stuff
id: 38565060255
link: http://joneisen.tumblr.com/post/38565060255/pycodejam-a-codejam-solution-runner-for-python
slug: pycodejam-a-codejam-solution-runner-for-python
publish: 2012-12-022
tags:
---


I love [Google Code Jam](http://code.google.com/codejam). I love solving problems, and Code Jam problems are fun! I also like competing, and since I wasn’t blessed with good athleticism or a desire to have good athleticism, Code Jam gives me a chance to compete using skills I am passionate about.

I like solving Code Jam problems in python. Python is very expressive, clear, and concise. If you worry about speed, 99% of the problems are solvable in python, but a language like C (being 1-2 orders of magnitude faster) will cover up more mistakes than python. Python has many useful objects in its standard library and language definition that make doing complex tasks easy. I will probably do a post about a bunch of those sometime, but for now, I’d like to introduce [pycodejam](https://github.com/yanatan16/pycodejam).

Every time I write a solution to a Code Jam problem, I have to rewrite code to feed in the input and write the output. I make mistakes a lot of the time and that costs me precious minutes during the competition. A while ago I wrote some basic functions and started copying them between every solution I wrote, but the code was ugly and didn’t contribute to the idea of solving the problem.

So I wrote a small library to help run code jam problems. In some problems, you could only need as little as 3 lines of code to run the problem. Here’s an example to motivate your interest:

Suppose the problem was to take 3 lines of integers, element-summing the first two as if they were vectors and comparing those values to the third, then the program should output ‘Case \#n: Yes’ if those vectors match, and ‘Case \#n: No’ if they don’t.

    def solve(v1, v2, vc):
      if all([x+y == z for x, y, z in zip(v1, v2, vc)]):
        return 'Yes'
      else:
        return 'No'

    if __name__ == "__main__":
      from codejam import CodeJam, parsers
      CodeJam(parsers.ints, solve).main()

The pycodejam parsers know how to interpret basic code jam input files. The simple parsers provided in the `codejam.parsers` module likes `ints`, `floats`, `words`, and `lines` assume there are a constant number of lines per case input. Once they figure that out, its a simple matter to interpret each line as an array of integers (as the `ints` parser does). For more complicated input files, such as those with variable lines per case, there’s a nice decorator called `custom_iter_parser` located in the [parsers](https://github.com/yanatan16/pycodejam/blob/master/codejam/parsers.py) module.

`pycodejam` is available on pypi and can be installed with `pip`. Checkout the [github repository](https://github.com/yanatan16/pycodejam) for more details. I’ll be adding some api documentation shortly.

