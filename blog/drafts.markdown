---
layout: default
title: The Pidgeonhole Principal
top: Blog
section: Blog

feed: atom.xml
keywords: Blog
---

The Pidgeonhole Principal
========================

This is my ([Jon Eisen](/)'s) blog about everything I like to do. I don't like to pidgeonhole myself into one thing. I like a lot of things.

More [information](info.html) about this blog and a complete archive of [past](past.html) posts, are 
available via links at the top of the page.

[![Feed icon](/files/css/feed-icon-14x14.png){:title="Atom feed of recent posts" .right}][feed]
A [feed][] of the most recent posts is also available.

[feed]: /iem/atom.xml

Recent Posts
------------

{% for post in site.drafts limit:5 %}
<div class="section list">
  <h1>{{ post.date | date_to_string }}</h1>
  <p class="line">
  <a class="title" href="{{ post.url }}">{{ post.title }}</a>
  </p>
  <p class="excerpt">{{ post.excerpt }}</p>
</div>
{% endfor %}

<p>
<a href="past.html">Older Posts &rarr;</a>
</p>
