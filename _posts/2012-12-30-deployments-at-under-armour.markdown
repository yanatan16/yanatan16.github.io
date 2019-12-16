---
layout: post
categories: programming
title: Deployments at Under Armour Part 2
date: Sun Dec 30 2012 19:36:00 GMT-0700 (MST)
redirect_from: /post/39269148417/

# Old tumblr stuff
id: 39269148417
link: http://joneisen.tumblr.com/post/39269148417/deployments-at-under-armour
slug: deployments-at-under-armour
publish: 2012-12-030
tags: capistrano, deployments, github, phenny, under armour, ua.com
---


When I was hired at Under Armour, I came in looking for a way to show that I can improve the team and our processes around me. I found a great candidate in our deployment system. Our old deployment system wasn’t really a “system” at all. To deploy to non-production servers, one of two developers who knew the process would RDP (yes its windows, sigh) to onto the box the server is hosted on and run a bash script, as well as copying new jars to the library folder, rebuilding js/css files manually, or updating the cache-busting key. Production deploys were even more manual. This “system” wasn’t consistent, repeatable, traceable, or easy to use. We couldn’t analyze the logs from a past deploy because they weren’t recorded at all.

I then read about [github’s deployment process](https://github.com/blog/1241-deploying-at-github). In this article, I was introduced to the deployment tool [capistrano](https://github.com/capistrano/capistrano), which is a glorified parallel ssh tool written in ruby. I’d also heard about deployment systems which are run from campfire and other team chat rooms. At UA, we use an internal IRC server, but I had to recruit everyone to use it as our main chat room. It has since become a great tool for our team communication.

My first goal was to validate that capistrano could deploy to our non-production servers efficiently, easily, and automatically. I was able to translate the bash scripts and manual tasks to capistrano tasks. Then I found an IRC bot to use for the deployment interface, [phenny](http://inamidst.com/phenny/). After writing the phenny module, I introduced it to the team. The team was happy to have an improved deployment system. After the process was validated for QA, I upgraded it to do a multi-phase deployment to production, which is currently used to improve our production deployments process.

The workflow now is to modify a capistrano configuration file on our github enterprise (which can be done entirely in a browser, thanks to the ACE web editor) to tell the system which repository and branch to deploy and then go into our IRC server deployments channel and execute the `.deploy <env>` command. The phenny module will then start a capistrano script for deployment in a new thread, outputting the logs to a file. The log files are accessible via a simple static file nginx webserver so users can monitor progress. Log files are also scanned for errors, failures, and warnings, which are outputted to the IRC channel to notify developers and QA of any errors in the deployment or failure of lint tests.

The entire capistrano deployment is custom-written for our unique configuration and deployment tasks. The only capistrano open source tasks I used were [multi-stage deployments](https://github.com/capistrano/capistrano/wiki/2.x-Multistage-Extension) and the git module. I even created a new copy/rsync deployment strategy that uses a local cache and builds the compiled files on the deployments server and rsync’d the files to a remote cache to speed up deployment time (as opposed to copying). I’d like to open source this at some point in the future. Its a pretty useful deployment strategy that is optimized for speed and efficiency.

These days, I am putting the finishing touches on version 2.0, which will simplify the configuration process to become project-based, instead of environment-based, introduce nightly tasks, add more IRC commands with better documentation, run mongo scripts on the local mongo boxes (as opposed to remotely, which can really damper deployments with large scripts), and add a fully automated rollback process, among other improvements. All in all, I wrote about 700 lines of ruby and 200 lines of python to create this system, which has given our development and operations team an easy way to deploy code to QA and production systems. With this process improvement, we ship more code more often, which helps us to “always be shipping.”
