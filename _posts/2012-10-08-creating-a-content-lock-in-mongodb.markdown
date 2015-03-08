---
layout: post
categories: development code
title: Creating a content lock in MongoDB
date: Mon Oct 08 2012 15:28:00 GMT-0600 (MDT)

# Old tumblr stuff
id: 33185206905
link: http://joneisen.tumblr.com/post/33185206905/creating-a-content-lock-in-mongodb
slug: creating-a-content-lock-in-mongodb
publish: 2012-10-08
tags:
---


Suppose you have a complex object or set of objects in your database, which happens to be MongoDB, and you can’t simply perform a single `db.coll.update()` call to write to it. It could be an ordered list, because mongo only knows sets, or it could be multiple objects in multiple collections. Here’s how you can create a lock in MongoDB.

First create a new collection for locks, and add this document to it:

    db.createCollection("locks");
    db.locks.ensureIndex({ name: 1 }, { unique: 1 });
    db.locks.insert({
        name: "mylock",
        locked: false,
        version: 1,
        uid: 0
    });

To take control of the lock then, try to update the lock object and double check you have it.

    var getLock = function() {
        this.myuid = Math.floor(Math.random()*10000000000);
        db.locks.update(
            { name: "mylock", locked: false },
            { $set: { locked: true, uid: myuid } },
            false, false);
        var haveLock = db.locks.count({ name: "mylock", uid: this.myuid });
        return haveLock;
    }

Then, once your done modifying the object, release the lock and update the version.

    var releaseLock = function() {
        db.locks.update(
            { name: "mylock", locked: true, uid: this.myuid},
            { $set: { locked: false }, $inc { version: 1 } },
            false, false);
    }

This allows you to have multiple agents modifying and reading the same complex object and using a lock stored in MongoDB.

