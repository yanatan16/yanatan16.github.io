---
layout: post
categories: programming
date: 2015-11-13 00:00:00
title: Reductions in Software and Startup Culture
---

In today's software and startup cultures, we often hear people take a complex idea and reduce it to a few words. These reductions seem, on the outside, to blur the lines between ideas. Essentially, by reducing a large possibility space to a smaller one, everything seems more similar than it really is. This is due to a simple mathematical idea: the [Pigeonhole Principle](https://en.wikipedia.org/wiki/Pigeonhole_principle), essentially stating that you can't fit all the information from a large possibility space into a small one.

However, although these reductions coarsely describe complex ideas, they do have value. One could argue that they must exist in order to help lay people _get_ the idea in question. They also give us a language in which to speak about complex ideas and make connections between ideas easier than otherwise. I'm going to consider a couple classes of reductions in software and startup culture and explore their usefulness.

<!--break-->

## Z for X

- [Uber for X](https://www.producthunt.com/e/uber-for-x)
- [Airbnb for X](https://www.producthunt.com/e/airbnb-for-x)
- [Tinder for X](https://www.producthunt.com/e/tinder-for-x)

Take a 2-minute startup elevator pitch. Reduce it to 3 or 4 words. Now you can sell it to investors. Easy right?

This reduction is **very** popular in today's startup culture. If you have a startup, you've probably got an "X for Y" reduction in the back of your mind. Take a successful startup (a [unicorn](https://en.wikipedia.org/wiki/Unicorn_%28finance%29)) whose core innovations (regardless of market) align with your startup, and replace that for Z. Then replace your startup's target market for X and whala! You now have a 3-word reduction of an idea you've spent countless hours thinking about.

These are often used to convey your startup's core idea (probably not new) and its market (also probably not new) to potential investors, employees, advisors, and others. It helps people get an initial grasp on what the innovation is (bringing a successful idea to a different market). The diligent among them will continue to ask questions and dive deep into figuring out whats beneath the "X for Y" reduction, but it was the reduction itself that allowed them to gain a foothold of understanding. This is especially useful for investors, who hear ideas for startups all the time and must either quickly understand a startup's intentions or not invest.

## Programming is X

- Programming is just moving data around
    - Generally, most programs _do_ just move data back and forth. But this reduction removes the complexities with both the movement of data, the consensus on data, and the changing nature of data.
- Programming is just making tradeoffs
    - Programmers make tradeoffs all the time, almost every line of code expresses a path of a tradeoff decision tree. But this reduction covers up the massive complexities involved with some tradeoff decisions (some have impacts years later).
- Programming is troubleshooting until it works
    - All programming is troubleshooting. We're all just trying stuff until it works. This reduction is completely true.

Reductions like these take a relatively complex field of work like programming and compare it to something easy to understand. Often it is hard for a programmer who has been making low-level decisions programming to examine the high-level impacts of his or her actions on the system. Reductions like these help a programmer step back from the "nitty gritty" to examine the meta-programming actions he or she is taking on the system being built or worked on.

For example, after wrangling with URL encoding problems all day, a programmer can step back and see that now data is flowing from the web browser to the server seemlessly and start to visualize the impact of that on the system.


---


Both of these reduction classes lose information, taking a complex domain and reducing it to a small possibility space of ideas. But, both have value to the cultures they belong to. It turns out the human brain is very bad at consuming complex ideas quickly, so we must invent shortcuts to help people to ingest data or transition viewpoints.

If you have any other reductions, [email them to me](mailto:jon@joneisen.works?subject=More+Reductions).
