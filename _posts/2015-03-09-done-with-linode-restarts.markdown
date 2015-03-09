---
layout: post
title:  Done with linode maintenance
date:   2015-03-09 19:30:00
categories: devops
---

This past week, we (at [Rafflecopter](http://make.rafflecopter.com)) were dealing with [Linode](http://linode.com)'s Xen Hypervisor [security updates](http://status.linode.com/incidents/2dyvn29ds5mz), the cause of which will be announced tomorrow, March 10. All I've got to say is *PHEW*. I'm glad its over with.

![phew](http://media.giphy.com/media/wIwrQ3umuEuM8/giphy.gif)

<!--break-->

It involved roughly 30 minutes of downtime for every one of our servers sometime throughout this past week, which caused us a bunch of headaches. I was able to construct a spreadsheet of downtime and a plan of action. Still, I discovered a few new issues:

- We had to rotate DNS to make sure people didn't experience downtime when our load balancers were taken offline.
- One of our applications needs a high file limit, but upon restart, it had the default (low) file limit, which always causes really weird errors. Adding the `minfds` option to our `supervisord.conf` took care of setting the file limit at boot time. (for [supervisor](http://supervisord.org/))
- [Redis](http://redis.io) [Sentinel](http://redis.io/topics/sentinel) had gone off the rails some time ago and decided to make all of our redis servers think they were slaves. So we had to turn sentinel off, which left us open to a single point of failure for applications that relied on Redis. This full restart of all our servers forced me into finding and fixing the reason it had gone crazy in the first place.
- Some emergency maintenance during Q4 2014 had us turn off automated load balance failover for one of our apps. This hell week of monitoring and rotating active instances of that application has gotten me the motivation to fix the problem. I'll soon be figuring a way to turn failover back on without breaking the application itself. (Its a high-traffic socket.io-based application that can fool nginx into thinking its not working due to non-gracefull socket termination.)
- Turns out that [Graphite](http://graphite.wikidot.com/) needs `/var/run/graphite` available when it starts, but in Ubuntu 12.04+, `/var/run` is tmpfs, which means it starts empty. I've switched Graphite's pid directory to something that doesn't get removed.
- We recently migrated a MySQL server off of a managed service onto our own servers. So I learned how to failover a MySQL server. Whilst not the hardest thing in the world. Rediscovering that my original [password was too long for replication](http://nerdherd.com/archives/524) was a pain in the ass.

Whilst I wouldn't wish this on my worst devops enemies, it is a necessary part of life, and I'm happy at least for the motivation to improve our setup.