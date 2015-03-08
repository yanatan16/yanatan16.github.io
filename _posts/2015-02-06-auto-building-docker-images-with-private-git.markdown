---
layout: post
categories: development code
date: Fri Feb 06 2015 11:22:00 GMT-0700 (MST)
title: Auto-building Docker Images with private git submodules

# Old tumblr stuff
id: 110265418306
link: http://joneisen.tumblr.com/post/110265418306/auto-building-docker-images-with-private-git
slug: auto-building-docker-images-with-private-git
publish: 2015-02-06
tags: docker, docker-autobuilder, git, github, dockerhub, submodules
---


So [Docker Hub](http://hub.docker.com) does this nice thing for you: If
you put up a git repository with a Dockerfile, Docker Hub will
auto-build a Docker Image for you every time you commit. This is great,
no longer do you have to sit through 10 minute `docker push` waiting
periods.

However, there is a fatal flaw. It cannot handle GitHub repositories
with private [git
submodules](http://git-scm.com/book/en/v2/Git-Tools-Submodules) (I’ll
post on my rational for using this inconvenience later). First, I’ll
explain why it cannot handle it:

Docker Hub uses a deploy key to pull the initial (probably private)
repository from GitHub. This is done with `git clone --recursive`, which
will also initialize and update submodules. During this clone, git will
try to pull the private submodule (also on GitHub), which will fail
because the ssh key being used is not valid for the second repository.

Docker Hub
[suggests](http://docs.docker.com/docker-hub/builds/#github-submodules)
that you just add the deploy key it used for the first repository to the
second repositories Deploy Keys page manually. This is not possible as
it returns this nice message from GitHub: `Key is already in use`.

So I solved this delimma by creating
[docker-autobuilder](https://github.com/yanatan16/docker-autobuilder).
Its a very simple [openresty](http://openresty.org/) app that uses some
lua to parse GitHub webhooks and run a docker build and push. Simply
stick an ssh key with appropriate GitHub permissions and login to docker
to autobuild to your hearts desire. And better yet, it runs in docker
itself!

