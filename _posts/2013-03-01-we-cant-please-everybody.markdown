---
layout: post
categories: philosophy
title: We can't please everybody
date: Fri Mar 01 2013 20:55:03 GMT-0700 (MST)
redirect_from: /post/44344332207

# Old tumblr stuff
id: 44344332207
link: http://joneisen.tumblr.com/post/44344332207/we-cant-please-everybody
slug: we-cant-please-everybody
publish: 2013-03-01
tags: development, heroku, best practices, hacker news
---


Recently on [hacker news](http://news.ycombinator.com), there was a post called [Heroku fucking console](http://news.ycombinator.com/item?id=5304936), where someone created a work-around because heroku had removed the functionality to simply call `heroku console`, and instead you now have to call `heroku run rails console`. This sparked a rather long comment thread with people complaining about “software that knows exactly what you want it to do, then gives some excuse as to why it’s not going to do it in an effort to get you to jump through meaningless hoops” ([link](http://news.ycombinator.com/item?id=5305056)).

While I do agree with this sentiment, software should be easy to use, not hard; this is not always easy to implement for the developer. The developer must think of everyone using his or her product, and sometimes must make choices which negatively affect some people’s experience in favor of the greater good. I scanned through the comment thread in question and came up with a few examples.

1.  `heroku console` is now `heroku run rails console`. There’s two good
    explanations here. `heroku console` spins up a new dyno and calls
    `rails console` for you to use. A new user might not know that by
    calling this command he is in fact being charged for the costs of
    running that one-off process. By explicitly saying
    `heroku run rails console`, a user will (should) read the docs on
    `heroku run`, and once knowing how that works, able to call the full
    command with knowledge of its execution. Secondly, rails was once
    heroku’s bread and butter, but it is no longer. It makes sense to
    remove application-specific language from an application-independent
    program.
2.  When saving a file in gimp, one cannot select .jpg format without
    being told to go to the export menu. Consider the fact that when an
    user unfamiliar with image formats tries to save his image as a
    jpeg, only to come back later to realize all his layer and shading
    information flattened to a single image! Consider the user
    experience there. Gimp gets around this by forcing the user to go to
    the export menu; thus understanding this is not a save that can be
    reversed.
3.  "If you change a file extension, the file may become unusable! Are
    you sure?" Most people using Windows need this message.
4.  Can’t `ctrl-C` out of man pages. This one was explained in the
    comments, but its because man uses `less` by default which has
    advanced features such a search that you can SIGINT to kill. You can
    change it with an environment variable, or just hit `q` to quit.

These are all choices made for the greater good, but some of which do not benefit the more experienced users. Sometimes we’re frustrated by those choices, but we must understand them, and work around them, like `heroku fucking:console`.

