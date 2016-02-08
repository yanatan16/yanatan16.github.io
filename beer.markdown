---
layout: page
title: Beer
permalink: /beer/
order: 2
---

{% assign beer_data = site.data.beer %}
{% assign srm_data = site.data.srm.srm %}

## On Tap

<ul class="on-tap">
    {% for beer in beer_data.ontap %}
        {% include beer.html beer=beer %}
    {% endfor %}
</ul>

## Bottled

<ul class="bottled">
    {% for beer in beer_data.bottled %}
        {% include beer.html beer=beer %}
    {% endfor %}
</ul>

## Next Up

<ul class="next-up">
    {% for beer in beer_data.upnext %}
        {% include beer.html beer=beer %}
    {% endfor %}
</ul>

## Kicked

<ul class="kicked">
    {% for beer in beer_data.history %}
        {% include beer.html beer=beer %}
    {% endfor %}
</ul>


<script src="/js/beer.js"></script>
