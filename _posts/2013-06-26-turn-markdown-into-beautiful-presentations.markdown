---
layout: post
categories: development code
title: Turn markdown into beautiful presentations
date: Wed Jun 26 2013 19:25:00 GMT-0600 (MDT)

# Old tumblr stuff
id: 53976752448
link: http://joneisen.tumblr.com/post/53976752448/turn-markdown-into-beautiful-presentations
slug: turn-markdown-into-beautiful-presentations
publish: 2013-06-026
tags: markdown, reveal.js, revealme, github
---


In a moment of need, I created
[revealme](http://revealme.herokuapp.com), an in-browser presentation
experience which can use straight Markdown to produce beautiful
presentations. Content files are hosted in github repositories and
presentations are rendered using
[reveal.js](http://lab.hakim.se/reveal-js/).

I had made the content for my [presentation on MongoDB
Indexes](http://revealme.herokuapp.com/yanatan16/mongodb-indexing-presentation)
in a markdown gist. I often use
[gistdeck](https://github.com/nzoschke/gistdeck) for ad-hoc
presentations, but since this was a bit more involved, I decided to look
into something more put together. (I really try to stay away from
Microsoft Office) I looked around for markdown -\> presentation
solutions, and found reveal.js.

However, reveal.js, as currently packaged on github, makes you download
the whole repository and edit an HTML file to make a presentation. We
live in a better age! I decided to create a simple github-proxy to load
html content into reveal.js’ `index.html` file. You simply use the same
path as you would for `raw.github.com`, and the server will go get that
file from github.

Once that was working, I added some more options, like being able to set
the page title, theme, or transition of the presentation in comments in
the html/markdown; as well as the theme and transition in query
parameters.

reveal.js by default doesn’t support straight markdown, just markdown
within each slide which means a lot of boilerplate! I decided to do
markdown parsing on the server side, and insert the appropriate

tags with level 1 and level 2 headers marking the beginning of slides.
Now, we can take any `README.md` file and make a great persentations.

For example, here’s a couple README’s that are now presentations:

-   <http://revealme.herokuapp.com/yanatan16/pycodejam>
-   <http://revealme.herokuapp.com/yanatan16/itertools>

Update: Revealme now supports gist-based files, a horizontal-only
option, and github flavored markdown.

