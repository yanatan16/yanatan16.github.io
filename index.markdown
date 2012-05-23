---
layout: default
title: Home

section: Home
---

<img class='inset right' src='/images/jon_eisen.jpg' title='Jon Eisen' alt='Photo of Jon Eisen' width='120px' />

Welcome
=======

I'm Jon Eisen.

+-- {.section}
Blog
=====
I keep a research [blog](/blog).
Recent posts include:
{% for post in site.posts limit:3 %}
<ul class="compact recent">
<li>
	<a href="{{ post.url }}" title="{{ post.excerpt }}">{{ post.title }}</a>
	<span class="date">{{ post.date | date_to_string }}</span> 
</li>
</ul>
{% endfor %}
=--
