---
layout: page
title: Beer
permalink: /beer/
order: 4
---

{% assign beer_data = site.data.beer %}
{% assign srm_data = site.data.srm.srm %}

## On Tap

<ul class="on-tap">
    {% for beer in beer_data.ontap %}
    <li class="beer">
        <h3 class="beer-name">{{beer.name}}</h3>
        <label class="beer-style">Style: {{ beer.style }}</label>
        <label class="beer-abv">ABV: {{ beer.abv }}</label>
        <label class="beer-ibu">IBU: {{ beer.ibu }}</label>
        <div class="beer-srm {% if beer.srm > 15 %}beer-srm-dark{% else %}beer-srm-ligth{% endif %}" style="background-color: #{{ srm_data[beer.srm] }}">color</div>
        <label class="beer-method">Method: {{ beer.method }}</label>
        <label class="beer-distribution">Distribution: {{ beer.distribution }}</label>
        <label class="beer-date">Date Finished: {{ beer.date }}</label>
        <p class="beer-description">{{ beer.description }}</p>
    </li>
    {% endfor %}
</ul>


## Next Up

<ul class="next-up">
    {% for beer in beer_data.upnext %}
    <li class="beer">
        <h3 class="beer-name">{{beer.name}}</h3>
        <label class="beer-style">Style: {{ beer.style }}</label>
        <label class="beer-abv">ABV: {{ beer.abv }}</label>
        <label class="beer-ibu">IBU: {{ beer.ibu }}</label>
        <div class="beer-srm {% if beer.srm > 15 %}beer-srm-dark{% else %}beer-srm-ligth{% endif %}" style="background-color: #{{ srm_data[beer.srm] }}">color</div>
        <label class="beer-method">Method: {{ beer.method }}</label>
        <label class="beer-status">Status: {{ beer.status }}</label>
        <p class="beer-description">{{ beer.description }}</p>
    </li>
    {% endfor %}
</ul>

## Kicked

<ul class="kicked">
    {% for beer in beer_data.history %}
    <li class="beer">
        <h3 class="beer-name">{{beer.name}}</h3>
        <label class="beer-style">Style: {{ beer.style }}</label>
        <label class="beer-abv">ABV: {{ beer.abv }}</label>
        <label class="beer-ibu">IBU: {{ beer.ibu }}</label>
        <div class="beer-srm {% if beer.srm > 15 %}beer-srm-dark{% else %}beer-srm-ligth{% endif %}" style="background-color: #{{ srm_data[beer.srm] }}">color</div>
        <label class="beer-method">Method: {{ beer.method }}</label>
        <label class="beer-distribution">Distribution: {{ beer.distribution }}</label>
        <label class="beer-date">Date {{ beer.distribution }}: {{ beer.date }}</label>
        <p class="beer-description">{{ beer.description }}</p>
    </li>
    {% endfor %}
</ul>
