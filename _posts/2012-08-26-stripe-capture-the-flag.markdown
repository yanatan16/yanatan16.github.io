---
layout: post
categories: development contest code
title: Stripe Capture The Flag
date: Sun Aug 26 2012 12:55:22 GMT-0600 (MDT)

# Old tumblr stuff
id: 30257181644
link: http://joneisen.tumblr.com/post/30257181644/stripe-capture-the-flag
slug: stripe-capture-the-flag
publish: 2012-08-026
tags:
---


I just finished the security vulnerability contest [Stripe
CTF](https://stripe.com/blog/capture-the-flag-20). Now this was a really
fun exercise. (Note: if its before Wednesday, Aug 26 2012, you still
have time to do the [Stripe CTF](https://stripe-ctf.com).)

Basically, [Stripe](http://stripe.com) set up 9 levels, each is a
standalone web server. Each level tested your ability to exploit a
security vulnerability in the webserver. It started out easy, with
solutions taking a small amount of effort, but by level 5 and 6, the
time per solution had raised significantly. Eventually, it came down to
a complicated multi-step strategy in level 8 (level numbers were
0-based, naturally). You can read more about it in their [blog
post](https://stripe.com/blog/capture-the-flag-20).

I’m a learning-by-doing sort-of person. I’ve heard of cross site request
forgeries and cross-site scripting before. I’ve known what SQL injection
is. But getting hands-on experience at trying to identify
vulnerabilities in source code and figuring out how you (the attacker)
actually executes the attack, in addition to all the nuances associated,
teach me a lot more about those vulnerabilities than anything else.

The vulnerabilities that I exploited during the competition were:

-   SQL regex globbing
-   Parameter expansion,
-   [SQL injection](http://en.wikipedia.org/wiki/SQL_injection) with
    UNION
-   CSRF ([cross-site request
    forgeries](http://en.wikipedia.org/wiki/Cross-site_request_forgery))
    with javascript injection
-   Arbitrary code uploads using a picture uploader
-   Acquiring ssh access to a webserver
-   Performing an [extension length
    attack](https://blog.whitehatsec.com/hash-length-extension-attacks/)
-   Doing a
    [brute-force](http://en.wikipedia.org/wiki/Brute-force_attack) (or
    as a former coworker called it, brutal force) attack on a flawed
    password-storage architecture.

I’m now a much more security-aware coder, and I’ll develop more secure
web code in the future. Thank you Stripe! And, I get a T-shirt! :D.

I’ll write up my solutions after next Wednesday, when the competition
ends.

