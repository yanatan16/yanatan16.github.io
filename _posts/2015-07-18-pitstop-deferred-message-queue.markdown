---
layout: post
title:  "Pitstop: A Deferred Message Microservice"
date:   2015-07-18 13:30:00
categories: architecture
crossposted:
  url: http://make.rafflecopter.com/pitstop-deferred-messaging-microservice.html
  name: rafflecopter dev-blog
---

My coworkers and I over at [Rafflecopter](http://www.rafflecopter.com) have been talking about a microservice whose sole job is to receive messages and re-emit them at a later time. This is a very specialized application which solves a problem that crops up a lot in many applications.

<!--break-->

The whole idea is that you want to be reminded to do something some time later. A naive solution is something like javascript's `setTimeout`. But what if your process crashes? Then you lose data. You'll need to take time to create a reliable solution using some data store.

This pattern crops up a lot of places. Our transactional email sender already had a poorly written solution to this problem. For example, we send emails reminding people to pick winners for their giveaways, and we schedule those when admins change their giveaway end dates.

Recently, we wrote an application that pulls information from services like twitter. It had to internally write a recurring version of this pattern to remind it to poll what it needed in a reliable way.

So since this pattern crops up a lot of places, we might as well extract it into its own microservice (or library if you prefer), then we never have to rewrite this code again.

Our solution to this is the clojure library [pitstop](https://github.com/Rafflecopter/pitstop). Feel free to check it out. Its still a young and immature library, but aimed to solve a common problem faced by distributed application developers.