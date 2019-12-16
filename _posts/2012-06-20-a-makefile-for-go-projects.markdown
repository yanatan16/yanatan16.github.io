---
layout: post
categories: programming
title: A Makefile for Go Projects
date: Wed Jun 20 2012 08:04:49 GMT-0600 (MDT)
redirect_from: /post/25503842796/

# Old tumblr stuff
id: 25503842796
link: http://joneisen.tumblr.com/post/25503842796/a-makefile-for-go-projects
slug: a-makefile-for-go-projects
publish: 2012-06-020
tags:
---


I’ve been making a websocket-based server in Go just for fun the past few weeks. I’ve really enjoyed working with Go. The concurrency model isn’t new, but its so easy and clean. The update to Go1 came with the easy-to-use `go` command, which encompasses the compiler, installer, cleaner, and tester. Also, it deprecated the previous commands gomake and goinstall, which were idiomatically used before Go1.

In Go1, it is idiomatic to create a small number of packages in your plugins, which are easy to retrieve using: `go get repo\_site.com/path/to/repo/package`, or including it directly in your go files, and running `go install`. These packages are easily built and installed using the go command. But for larger projects which have many dependent packages and commands, I needed an easier way to build it all.

I created the Makefile.golang file in this [gist](https://gist.github.com/2951128 "Makefile.golang gist"). It creates the usual targets, all, build, test, install, clean.

`make` will format (with gofmt), install dependencies, and build all the packages listed in the Makefile. `make test` will run tests for all packages. `make install` and `make clean` work as expected as well.

To use, simply make sure you have GNU make and Go1 installed. Put it in your top level package under the GOPATH. Configure the package lists to all your packages you’d like to build, and whalah!
