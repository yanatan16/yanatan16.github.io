---
layout: post
categories: programming
title: Making Clean and Reusable Salt States
date: Tue Jun 10 2014 16:30:00 GMT-0600 (MDT)
redirect_from: /post/88414528746/

# Old tumblr stuff
id: 88414528746
link: http://joneisen.tumblr.com/post/88414528746/making-clean-and-reusable-salt-states
slug: making-clean-and-reusable-salt-states
publish: 2014-06-010
tags: saltstack, DRY, jinja
---


*Co-blogged on [make.rafflecopter.com](http://make.rafflecopter.com/clean-salt-states.html)*

When I first created our [SaltStack](http://saltstack.org) system, I violated the DRY (Don’t Repeat Yourself) principle somewhat due to speed, but mostly due to unfamiliarity with the system. I recently fixed that with a negative 3000 line commit. Here’s some of the things I learned that allowed me to create better (i.e. cleaner and reusable) salt states.

### Jinja Imports

Use `jinja` imports! I was writing and rewriting the same jinja variable definitions in so many files. It turns out you can import those variables from a global location, eliminating jinja variable definitions!

<code data-gist-id="6d1ed08b5aacc9b5690f" data-gist-file="global_vars.jinja"} ``{data-gist-id="6d1ed08b5aacc9b5690f" data-gist-file="app-init.sls"></code>

### Jinja Macros

Use `jinja` macros! I like to have our applications similarly configured, so I was also rewriting the same lines of `json` in so many files. Macros and importing helped eliminate this.

<code data-gist-id="6d1ed08b5aacc9b5690f" data-gist-file="macros.jinja"} ``{data-gist-id="6d1ed08b5aacc9b5690f" data-gist-file="app-config.json.jinja"></code>

### Custom States

Use custom states. Sometimes theres a thing you want to configure on a machine, but no state exists in the extensive list of [salt states](http://docs.saltstack.com/en/latest/ref/states/all/index.html) for it. You can make your own! This example is taken from [Publysher Dev Blog’s Infra As a Repo series](http://blog.publysher.nl/2013/08/infra-as-repo-securing-your.html). Just stick any module and state in `/srv/salt/_modules` or `/srv/salt/_states` (or wherever your `file_roots` are).

<code data-gist-id="de07bf489986754402fc" data-gist-file="_modules-ufw.py" data-gist-line="1-3,15-19"></code>
<code data-gist-id="de07bf489986754402fc" data-gist-file="_states-ufw.py" data-gist-line="62,76-78"></code>

### Build a System

Use everything I’ve said together to *program* saltstates using configuration (via pillar), code (via custom modules), state generation (via jinja templating), and generic states.

#### Pillar Configuration

<code data-gist-id="ea0553959c8ce3f7f778" data-gist-file="pillar-appspecs.sls"></code>

#### Custom Module

<code data-gist-id="ea0553959c8ce3f7f778" data-gist-file="roots-_modules-generics.py" data-gist-line="10-19"></code>

#### State Generation

<code data-gist-id="ea0553959c8ce3f7f778" data-gist-file="roots-apps-init.sls" data-gist-line="7-21,42-52"></code>

Theres so much more you can build on top of a system like this. It will save you code *and sanity*. You can create tens or hundreds of apps that are only differentiated by small configurations. You can deploy different revisions to different servers whenever you want. Good luck
building a generic saltstack app deployment system of your own!
