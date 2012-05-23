---
layout: default
title: Archives
section: Past

feed: atom.xml
keywords: Blog
---

Archives
========

This is the complete archive of posts from _[my blog](/blog)_
in reverse chronological order.

{% for post in site.posts %}
<div class="section list">
  <h1>{{ post.date | date_to_string }}</h1>
  <p class="line">
  <a class="title" href="{{ post.url }}">{{ post.title }}</a>
  </p>
  <p class="excerpt">{{ post.excerpt }}</p>
</div>
{% endfor %}
