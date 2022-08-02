---
title: Data Engineering Lessons
layout: post
categories: programming
date: 2022-08-01 22:00:00
---

The last six years or so of my career has been focused on data design and engineering. There are many problems organizations face around data, and I have been trying to solve them. Here's a few of the lessons I've learned along the way:


### Helping developers to care about data quality

Data is valued by organizations and business analysts, but often shunned by developers. Developers are the ones responsible for instrumenting the source of the data. Most of the time, this results in poor data quality. And, we all know the adage "garbage in, garbage out." So how do we make developers care more about the data they create?

I've seen organizations try to force developers to create data by making it part of the definition of feature-complete. But this rarely results in good quality data. My preferred solutions to this problem are:

- Make the data visible easily and quickly. This way, developers can verify their work. Too many times, I've seen data systems where developers cannot even look at the data they are creating without asking a data analyst for help.
- Make the data testable. Then test it. Make tests to verify that a user action causes data to come out. Most good developers like tests. Tests give them confidence. But developers generally only test things that are easy to test. So make data easy to test.
- Show developers the value of data. Show them how designed information can be more useful than a printed line. Show them how the data can describe the system itself, and how it can be leveraged to simulate and learn about its users.

### Smarter tools

Typically, organizations build or use systems to visualize and inspect data _agnostic_ to the data itself. Tools like Tableau and Superset are excellent for data analysts. But, I have found that we can derive significantly more value from custom-built tooling that leverages _a priori_ knowledge of the underlying data.

My favorite example of this is the Apple Health app. It contains a lot of data, but it doesn't show each kind of data the same. Instead, the authors have been careful to display each kind of data differently and with varying degrees of detail. This takes a lot of work, but it is far more valuable than if the app was simply a collection of values and charts with no understanding of the meaning of the data.

### Automating feedback loops

Data is often used to create metrics for making human decisions, but this is short of the true goal of data engineering, leveraging data to make decisions in automated feedback loops.

The golden example of an automated feedback loop is an eCommerce recommendation system. These have been in use for many years, and most are completely automated. At some cadence, the systems will leverage user behavior data to evaluate relationships between items and then update the "recommended" items. Then, when a user visits an item, they will see updated recommendations without a human-in-the-loop.

(Side note: Netflix's recommendation system also leverages information about the movies themselves. They believe that using underlying information about the movies makes it a better system, thus adding weight to my point about [Smarter Tools](#smarter-tools).)

But, often, building custom feedback loops with data is very challenging for organizations. It takes high quality data and good feature vision, and it can create excellent features for users.
