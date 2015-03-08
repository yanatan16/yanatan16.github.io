---
layout: post
categories: development code
title: My mongorc file
date: Sat Aug 03 2013 21:33:21 GMT-0600 (MDT)

# Old tumblr stuff
id: 57301176300
link: http://joneisen.tumblr.com/post/57301176300/my-mongorc-file
slug: my-mongorc-file
publish: 2013-08-03
tags: mongo, mongorc, mongodb, authentication, devops
---


Most of my coworkers use [MongoVue](http://www.mongovue.com/) to browse our Mongo database. I, being partially stubborn and somewhat allergic to Windows, have stuck with the mongo shell. In order to keep my productivity up, I started using a mongorc file.

The mongorc file is a lot like your bashrc file. It gets loaded every time you enter the mongo shell. It lies in your home directory and should be named `.mongorc.js`. Its just plain old javascript, but it can make a world of difference when operating in the shell day-to-day. I’ve generalized my personal mongorc in [this gist](https://gist.github.com/yanatan16/6148978) and here, I’ll walk through it.

    (function () {
    rcversion = '1.0';

    load('underscore.min.js')

Just the basics here: wrap the whole thing in a closure, set a version for sanity’s sake, load underscore (a must in any javascript environment).

    (function () {
        var cmdCount = 0;
        var isMaster = db.isMaster();

        if (isMaster.setName) {
            prompt = function () {
                return isMaster.setName +  '(' + (isMaster.ismaster() ? 'pri' : 'sec' ) + '):' + db + '-' + (cmdCount++) + ' > ';
            };
        } else {
            prompt = function () {
                return db + '-' + (cmdCount++) + ' > ';
            };
        }
    })()

Setup the prompt: This prompt tells us if we are on a replica set, and if we are on the primary. It also shows the current database and the current command count.

    var login = function (dbname, username) {
        // Or load('auth_tokens.js')
        var tokens = {
            'admin-username': 'admin-password',
            'readonly-username': 'foo-readonly-password',
            'readwrite-username': 'foo-readwrite-password'
        };
            // Only login on the correct database.
        if (dbname !== db) {
            db.auth(username, tokens[username]);
        }
    };

    auth = {
        admin: _.bind(login, 'admin', 'admin-username'),
        ro: _.bind(login, 'foo', 'readonly-username'),
        rw: _.bind(login, 'foo', 'readwrite-username')
    };

Setup authentication helpers: Add in your own authentication schemes and tokens. You can also load these from another file. We basically, provide a nice function like `auth.admin()` to login to the admin database and others. Notice how that if we call this accidentally, we just drop it on the floor. This ensures you don’t get bothered when not on the authenticated database.

    _.mixin({
        // A deep getter
        get: function (obj, key) {
            return _.reduce(key.split('.'), function (o, k) {
                return o && o[k];
            }, obj);
        },

        // Get a random integer
        randint: function (n) {
            return Math.floor(Math.random() * (n || 2));
        },

        // Get a random choice
        randchoice: function (seq) {
            return seq[_.randint(seq.length)];
        },

        // Get the current timestamp
        now: function () {
            return (new Date()).getTime() / 1000;
        },

        // Create an object id based on a timestamp
        oid: function(timestamp) {
            if (!timestamp) {
                return new ObjectId();
            }

            // Convert string date to Date object (otherwise assume timestamp is a date)
            if ( ! timestamp instanceof Date ) {
                timestamp = new Date( timestamp );
            }

            // Convert date object to hex seconds since Unix epoch
            var hexSeconds = Math.floor( timestamp / 1000 ).toString( 16 );

            // Create an ObjectId with that hex timestamp
            return ObjectId( hexSeconds + "0000000000000000" );
        },

        // Aggregate sequence into prefix sequences
        aggregate: function (seq) {
            return _.reduce(seq, function (memo, nxt) {
                var agg = memo[0], cur = memo[1].concat(nxt);
                return [agg.concat([cur]), cur];
            }, [[], []])[0];
        },

        // Aggregate and join a sequence of strings
        aggjoin: function (seq, sep) {
            return _.map(_.aggregate(seq), function (agg) {
                return agg.join(sep);
            });
        },

        // Sum a sequence of numbers
        sum: function (seq) {
            return _.reduce(seq, function (a, b) { return a + b; }, 0);
        }
    });

Various useful helper functions: I just stick them on the underscore object to make using them easer. I don’t have to remember multiple helper objects. Especially helpful is \_.oid, which is oddly missing from the shell functions.

    // Walks a recursive object (`node`), testing them with tester and making callbacks when tester returns true.
    // The only option is `depth`: defaults to 20 but can be set arbitrarily (up to shell limit) to control recursion.
    var walker = function (node, tester, callback, opts) {
        depth = (opts || {}).depth || 20;
        var walk;
        walk = function (branch, n) {
            n = n || 0;
            if (n > depth) return null;

            if (tester(branch)) {
                callback(branch);
            }

            if (_.isObject(branch) || _.isArray(branch)) {
                _.each(branch, function (subbranch) {
                    walk(subbranch, n + 1);
                });
            }
        }
        return walk(node);
    };

This is a base function for walking a tree structure to find things. Mongo is based off of javascript objects, which are so easy to nest. We have some arbitrarily nested structures in our database, and parsing them in the shell is tedious at best. We’ll start with this and build up some useful functions for dealing with arbitrarily nested data.

    // Take a selector and create a testor for the walker function
    // The goal is to create a tester that will find objects with certain key/value pairs.
    // Selectors can be strings, objects, or arrays.
    // Objects and arrays just create AND filters trying to match part of objects
    // String filters can be 'FIELD:' (to search for having the field 'FIELD')
    // or 'FIELD:VALUE' to search for string equality.
    var kv_typetest = function (selector) {
        var expect = {}, match = {}, tests = [];
        if (_.isString(selector)) {
            _.each(selector.split(' '), function (sel) {
                var kvsplit = sel.split(':');
                if (kvsplit.length === 1) {
                    expect[kvsplit[1]] = true;
                } else if (kvsplit.length === 2) {
                    match[kvsplit[0]] = kvsplit[1];
                }
            });
        } else if (_.isObject(selector)) {
            expect = selector;
        } else if (_.isArray(selector)) {
            tests = _.map(selector, kv_typetest);
        } else {
            throw new Error("Expected string or object for selector");
        }

        return function (branch) {
            return _.every(expect, function (value, key) {
                if (value instanceof RegExp) {
                    return value.test(_.get(branch, key));
                } else {
                    return _.isEqual(_.clone(_.get(branch, key)), value);
                }
            }) && _.every(match, function (_value, key) {
                return branch.hasOwnProperty(key);
            }) && _.every(tests, function (t) {
                return t();
            });
        };
    };

Here, I start to build a tester function for the walker base function. We start to introduce something of the ease of jquery selector syntax for finding objects nested deeply in data. It’s not fully featured, and can’t find children, but it works well for what it does.

    // Select the children of element based on tester
    // If tester is not a function, use kv_typetest to create one
    // Options are pass-throughed to walker.
    var selector = $ = function (element, tester, opts) {
        var buf = [];

        if (!_.isFunction(tester)) {
            tester = kv_typetest(tester);
        }

        var callback = function (branch) {
            buf.push(branch);
        };

        walker(element, tester, callback, opts);

        if (buf.length === 1)
            return buf[0];

        return buf;
    };

Selector is the third and final piece in this selection feature. It allows one to do something like `$(nested_obj, 'hello:world')` to find all nodes with {hello: ‘world’} in it.

    // Or load('app_specific_mongorc.js');
    _.mixin({
        session: function (key) {
            return db.sessions.findOne({_id: key});
        },
        invalidate_session: function (key) {
            return db.sessions.remove({_id: key});
        },
        // add your own
    });

This is a great place to put application-specific helper functions for helping you deal with the day-to-day tasks in your database.

    // Autologin
    auth.ro();

    })();

Finally, auto-login into read-only mode and execute the closure. Logging into read-only mode has saved me so many times from making buggy not-ready changes because I thought I was local or in QA.

