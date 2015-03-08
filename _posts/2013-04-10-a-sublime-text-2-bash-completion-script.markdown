---
layout: post
categories: development code
title: A Sublime Text 2 Bash Completion Script
date: Wed Apr 10 2013 07:25:00 GMT-0600 (MDT)

# Old tumblr stuff
id: 47618192514
link: http://joneisen.tumblr.com/post/47618192514/a-sublime-text-2-bash-completion-script
slug: a-sublime-text-2-bash-completion-script
publish: 2013-04-010
tags: sublime text 2, bash, bash completion
---


tl;dr: Here’s a bash script and an accompanying bash completion script that opens Sublime Text 2 projects.

I love [Sublime Text 2](http://www.sublimetext.com/2). Its fast, lightweight, powerful and it doesn’t get in your way. I also context switch between projects a lot. Sometimes I’ll work on 5 different projects in one day at work. In order to keep my head straight, I use sublime text’s notion of a project. A project is, at its core, just a list of folders to keep open in the sidebar. To create a project, just add a folder to your sidebar, and then save the project.

Once you have a few projects, you’ll inevitably want to open them from the command line, and doing so can be cumbersome. (Sorry about the encoded ampersands, I’m working on fixing it.)

    sublime_text --project /path/to/projects/myproject.sublime-project &amp;

So I decided to create a little bash script to open up all the projects I want.

    #!/usr/bin/env bash
    for proj in $@; do
        sublime_text --project /path/to/projects/${proj}.sublime-project &amp;
    done

Suppose I put this in a file called `subl` on my \$PATH. Then I can type `subl myproject` to open any project. Now, since I have \~20 projects, its hard to remember all the names, so I created a bash completion script.

    _subl()
    {
      local cur=${COMP_WORDS[COMP_CWORD]}
      local list=`ls -1 /path/to/projects/*project | cut -d/ -f5 | cut -d. -f1`
      COMPREPLY=( $(compgen -W "${list}" -- ${cur}) )
    }
    complete -F _subl subl

Now I can type `subl myp[tab]` and it will autocomplete for me!

By the way, Under Armour is looking for a [Front-end architect](https://career8.successfactors.com/career?career_ns=job_listing&company=ua&navBarLevel=JOB_SEARCH&rcm_site_locale=en_US&career_job_req_id=5042&selected_lang=en_US&jobAlertController_jobAlertId=&jobAlertController_jobAlertName=&_s.crb=K%2fpaKqgxk88QlOgkVTaL8KN9ISA%3d) and [DBA](https://career8.successfactors.com/career?career_ns=job_listing&company=ua&navBarLevel=JOB_SEARCH&rcm_site_locale=en_US&career_job_req_id=5022&selected_lang=en_US&jobAlertController_jobAlertId=&jobAlertController_jobAlertName=&_s.crb=K%2fpaKqgxk88QlOgkVTaL8KN9ISA%3d). If you’d like to be a part of one of the coolest workplaces in Baltimore, check it out.

