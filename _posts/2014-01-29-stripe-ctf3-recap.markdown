---
layout: post
categories: development code contest
title: Stripe CTF3 Recap
date: Wed Jan 29 2014 20:00:00 GMT-0700 (MST)

# Old tumblr stuff
id: 75008410654
link: http://joneisen.tumblr.com/post/75008410654/stripe-ctf3-recap
slug: stripe-ctf3-recap
publish: 2014-01-029
tags: stripe, stripe-ctf, ctf, code-competition, go, haskell, node.js, scala
---


[Stripe CTF 3](https://stripe-ctf.com) just finished. It was awesome.
This year, it focused on distributed computing. I’ll walk through the
problems and my solutions.

Level 0 - Set Membership
------------------------

Level 0 gave you a small ruby program that read in a dictionary and a
list of words and checked to see if the words were in the dictionary.
The problem was to make this program faster:

``{data-gist-id="8675360" data-gist-file="level0.rb"
data-gist-line="8-19"}

It should be clear to most anyone with a small experience with data
structures that the basic solution is to convert the list of dictionary
words to a set. Ruby’s `.to_set` works fine. That got you a passing
score.

To do better, you first had to get lower level, going into C++/C helped.
Then you could see that the dictionary never changed and you can
serialize the dictionary so that your program didn’t incur the cost of
creating the set structure. You could use a structure with super-fast
lookups, like a [Bloom
Filter](http://en.wikipedia.org/wiki/Bloom_filter) or Hash Set. This
would probably get you to a score of 300-600.

To get more, you could get creative. When Stripe ran your test code,
they first run a `./build.sh` script. In that script, you could start a
process that compiled the dictionary and listened on a unix socket for
the “real” program to be called; this way no initialization cost at all!
This score could really get high, like 1000+. (Doesn’t work — See
update.)

UPDATE: According to @thegdb, the real trick was to use a remote process
to execute the work. However, this “bug” was patched out by the end of
the competition using CPU monitoring.

And according to [KJ](https://github.com/kjvalencik), the interprocess
communication wouldn’t work because of the LXC container environment,
however, a shared memory solution would work, but reading the shared
memory block takes time. Scores about 1000.

Here’s my solutions:
[ruby](https://gist.github.com/yanatan16/bf06f4dc0f43f66d38cd#file-level0-rb),
[haskell
bloomfilter](https://gist.github.com/yanatan16/bf06f4dc0f43f66d38cd#file-level0-bloomfilter-hs),
[haskell
set](https://gist.github.com/yanatan16/bf06f4dc0f43f66d38cd#file-level0-set-hs)
and
[C++](https://gist.github.com/yanatan16/bf06f4dc0f43f66d38cd#file-level0-c++).
Note that haskell solutions didn’t pass because compiling the data
structure, even with the ST monad (mutability), took way too long.

Level 1 - Gitcoins
------------------

Level 1 introduced a new cryptocurrency, the Gitcoin. A gitcoin is mined
a lot like a bitcoin, but uses the git commit hashing system.
Essentially, to add a gitcoin to your account, you increase your count
in a `LEDGER.txt`, then commit that with a commit message such that the
commit’s hash is below some difficulty level, such as starting with
3 0’s, like `0001ba23`.

To solve this, you basically just have to reverse engineer the git
object hashing scheme. Although, if you missed the link to the [git book
on git object
internals](http://git-scm.com/book/en/Git-Internals-Git-Objects), you
had a much harder time with this one. I didn’t bother to really optimize
my code, I just left it running overnight (after staying up til 3am) and
in the morning, I had a gitcoin and solved level 1!

To get higher scores, you had to compete for gitcoins in a global pool.
I never did get around to running this, but obviously, parallelism and
heavy-duty VPS instances would have helped.

My solution in
[haskell](https://gist.github.com/yanatan16/a4517f4804166855c58a).

Level 2 - DDOS Shield
---------------------

Level 2’s problem was to protect a fragile server from a DDOS attack. A
few number of attackers were sending a lot of requests and breaking the
fragile server, while a lot of valid users who sent relatively few
requests were supposed to be let by. The solution is scored as valid
requests that get correctly returned minus any idle time of the servers.

The basic solution is to just count requests by IP and not let anything
by that has more than X requests. Since each valid user is hardcoded to
only send 4 requests (2 per round) in the test runner, you can set this
to 4 or 5 and move on to level 3. To do better though, you’ll need some
sort of pressure-based routing that allows a known bad request through
if your servers are idle.

No need to show solution here, as its pretty simple.

Level 3 - Distributed Full Text Search
--------------------------------------

In level 3, your given a directory of files to index and setup a web
server with a query interface. Upon getting a query, your job is to
return the file and line number of every instance of the query which
could be a word or a sub-word. Immediately, you think about doing an
inverted index to solve this.

The example code was given in Scala, which is a nightmare to work with.
Just compiling a simple program took a minute and running it had all
sorts of JVM costs. Once I switched to node.js, I could run an entire
test in under 15 seconds, whereas Scala took 2 minutes. This sped up
development time considerably.

My first try was to do a basic inverted index, but this ended up having
weird issues with node’s objects. Turns out they don’t like objects with
250,000 keys. I turned to the npm module
[hashmap](http://npmjs.org/hashmap). Then I started to realize that any
given query could be a sub-word of any other word, so you have to search
the list of all words in order to find every word that may contain the
query. This cost considerable time, but a solution like this could still
pass (required score: 400). (Note: Using n-grams took too much time to
index)

Your given 4 servers to work with (1 master and 3 slaves), so
appropriate breaking up the work could really speed things up.
Initially, I just split up the work of parsing the directories, but then
I ended up with each slave having \~250K words in its inverted index. A
smarter way is to have each server handle a quarter of the dictionary so
any lookup (which takes O(n) because of the subword search) took a
quarter of the time. This is what gave the best bonus to the score.

After I did all this work on this problem, I learned from a friend that
a very simple call to `grep` and parsing the results could get you a
650. Boo on that.

Here’s my solution in
[node](https://gist.github.com/yanatan16/9694fc5cae878bbe90d8). This
ones pretty messy because it was tough to get right.

Level 4 - Distributed Fault-Tolerant CP Database
------------------------------------------------

Level 4 was all about building a distributed SQL database. Given a basic
SQLite wrapper with a very stupid replication algorithm in Go, make that
replication/fault-tolerance very good. It was tested using
[octopus](https://github.com/stripe-ctf/octopus), which would totally
nuke parts of your network, creating partitions, killing nodes, and
slowing the whole network. How, in those conditions, can you operate an
ACID CP database?

First of all, if your looking for reading on this topic, you should
check out these: [CAP
Theorem](http://en.wikipedia.org/wiki/CAP_theorem), [Two Generals
Problem](http://en.wikipedia.org/wiki/Two_Generals'_Problem), [Jepsen
Blog](http://aphyr.com/tags/jepsen), [The
Log](http://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying),
[Raft](https://ramcloud.stanford.edu/wiki/download/attachments/11370504/raft.pdf).

This was clearly the hardest problem, and with less than 200 captures by
the end, it showed. The first problem to solve here is how to gain some
distributed consensus about the state of the database. There are lots of
protocols out there, but one of the more recent ones is Raft. Its much
more understandable than Paxos, and it happens to have a Go
[implementation](https://github.com/goraft/raft). Using the [reference
implementation](https://github.com/goraft/raftd), you can bring raft
into the sqlcluster application pretty easily. After solving some stupid
bugs with socket locations, this will get you a working fault-tolerant
DB that has a single master, and can do failovers and replication.
Unfortunately, it’ll be tough to get a score over 50 (passing) without
some help.

Scoring for this problem was \# of successful queries (with a valid and
incrementing sequence ID) times 10 minus some measure of network
traffic. I solved the problem of finding more points by doing more
successful queries. A friend solved it by decreasing network traffic.
Both are valid.

To decrease network traffic, don’t actually setup a distributed network.
It creates a single point of failure with your node of choice, but since
the tester only tests a single node for SPOF, you have an 80% chance of
passing. Without replication, you’re golden to be able to just make a 50
on the test. UPDATE: Theres some questions about whether this was
possible after the bugfixes went into octopus; but the answer is yes, it
was still possible to get barely over 50 if you got lucky with your run.

To increase successful queries, you need to accept queries to slaves.
Those slaves can’t actually process the queries, so they have to proxy
them to the master using HTTP. But, consider the following case. A
proxied request reaches the master and is successfully executed. The
response containing the correct SQL response and sequence number is lost
due to the network failure. The slave responds with an error and the
whole test stops because now you’ve missed a sequence number! This is
known as the [Two Generals
problem](http://en.wikipedia.org/wiki/Two_Generals'_Problem). My
solution was to first attach a unique key to each proxied request. Then,
after proxying a request, if a slave did not receive a response, instead
of returning an error code, it would wait for its SQL instance to
process that specific request (with the correct unique key). Once it
did, the slave returned the response to the waiting test runner.
Basically, instead of using a lossy communication (HTTP), I used a
consistent communication channel (the shared log of SQL queries).

My [full solution](https://github.com/yanatan16/stripe-ctf3-level4).

------------------------------------------------------------------------

Overall, this was a great competition. I thought the topics were well
chosen, and I had a great time with it. My favorite levels were the
gitcoin mining and distributed database. I’d been meaning to use raft at
some point, and now I have! Thank you Stripe for putting in the hard
work to create such a fun and rewarding opportunity. I look forward to
receiving my t-shirt!

