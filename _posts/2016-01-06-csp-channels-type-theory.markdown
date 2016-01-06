---
title: CSP Channels in Type Theory
layout: post
section: index
date: 2016-01-06 12:00:00
categories: type-theory csp
---

[Communicating Sequential Processes][csp] (CSP) has become a [popular][go-concurrency] [solution][core-async] for simplifying concurrent programming. In its modern implementations, it is the communication of [green threads][green-threads] via channels, a uni-directional, possibly-bufferred, closeable queue of data.

Here, I'll give instance definitions for the channel in various type theory abstractions using Clojure's [core.async][core-async] and [cats][cats] (`cats.labs.channel`). We'll implement all of cats' main protocols: Semigroup, Monoid, Functor, Applicative, Monad, MonadZero, and MonadPlus.

<!--break-->

In cats, to create a type theory implementation, you must extend the type you want with the protocol `Contextual`, which contains a function to create a reified object with the actual implementation of the protocols:

<code data-gist-id="cf00fa7ed9259b9951ee" data-gist-line="109-112"></code>

In each of the implementations below,

- I'll show only the protocol implementations for `context`.
- `mv` stands for Monad Value and is a channel.
- `core.async` is imported as namespace `a`
- `cats.core` is required and refers all values (such as `mlet`, `bind`, `pure`, etc)

### Equality

These implementations below rely on satisfying laws of equality. Here is the equality I mean when comparing channels:

```clojure
(defn chan-eq? [c1 c2]
  (= (a/<!! (a/into #{} c1))
     (a/<!! (a/into #{} c2))))
```

Note the use of sets here. This means that we do not care about the _ordering_ of channel elements.

Channel order represents the coupling of time and data. Rich Hickey is always talking about decoupling time from applications. Hence, representing order in channel equality is against this idea. Therefore I chose an order-agnostic equality function. (It also has good properties for `mappend` [below](#semigroup--monoid).)

- [core.async/into](https://clojure.github.io/core.async/#clojure.core.async/into)

### Functor

A functor is a container type with a mapping function `(fmap f functor-value)`, akin to list's `map`:

<code data-gist-id="cf00fa7ed9259b9951ee" data-gist-line="65-67"></code>

Here, we are piping the channel through a transducer channel, which will apply `(map f)` to each element through the channel. `pipe` will handle closed channels and close the transducer channel when the input channel closes.

```clojure
(fmap inc (a/to-chan [1 2 3])) ; => channel containing [2 3 4]
```

- [core.async/pipe](https://clojure.github.io/core.async/#clojure.core.async/pipe)
- [core.async/chan](https://clojure.github.io/core.async/#clojure.core.async/chan)



### Semigroup & Monoid

A Semigroup is a type with an _appending_ function `(mappend mv1 mv2)`. A Monoid is a Semigroup with a _zero_ element: `(mzero)`. `mappend` must be associative and have `mzero` as its identity:

```clojure
;; Monoid Laws
(= c (mappend c (mzero)))
(= c (mappend (mzero) c))
(= (mappend c1 (mappend c2 c3))
   (mappend (mappend c1 c2) c3))
```

<code data-gist-id="cf00fa7ed9259b9951ee" data-gist-line="69-75"></code>

To `mappend`, we `a/merge` channels, and the zero channel is an empty, closed channel. When merged, the zero channel will not change the contents of the output channel, therefore it is an identity.

Choosing `a/merge` is a personal choice. It does not preserve order, like the list's `mappend`. But, since we chose an order-agnostic equality [above](#equality), it satisfies the laws. Other choices for `mappend` are appending the inner items in pairs as they are received, or strict ordering concatentation. I chose to use merge because merge handles unbalanced channels, especially infinite streams of data.

```clojure
(mappend (a/to-chan (range)) (a/to-chan [:data])) ; => chan #{:data 0 1 2 3 ...}
```

- [core.async/merge](https://clojure.github.io/core.async/#clojure.core.async/merge)
- [core.async/to-chan](https://clojure.github.io/core.async/#clojure.core.async/to-chan)

### Applicative

An Applicative is a container type with two functions: `(pure v)` wraps a value into the applicative type. `(fapply af av)` applies functions which are wrapped in the applicative to values wrapped in the applicative. For channels this means apply a channel of functions to a channel of values, like

```clojure
(fapply (pure inc) (pure 5)) ;=> chan #{6}
```

```clojure
;; Applicative Laws
;; Identity
(= c (fapply (pure identity) c))
;; Composition Application
(let [comp' (fn [f] (fn [g] (comp f g)))]
  (= (fapply (fapply (fapply (pure comp') cf) cg) cv)
     (fapply cf (fapply cg cv))))
;; Homomorphism
(= (fapply (pure f) (pure v)) (pure (f v)))
```

<code data-gist-id="cf00fa7ed9259b9951ee" data-gist-line="77-82"></code>

In `pure`, we usually just wrap a value with a channel with the value on it and closed. We handle the case of `(pure nil)` which is used as a throwaway value. We can't return an empty channel because then no application will be called, so we return a namespaced nil keyword. As long as one does not rely on the actual value inside `(pure nil)`, it satisfies all laws.

`fapply` is defined using `a/map`, which simply takes an element from each channel (`af` and `av`), and applies the function to it, which returns the application of the function from `af` to the value from `av`. It handles infinite channels and closes when one of the input channels closes.

```clojure
(fapply (a/to-chan (map (fn [n] #(+ % n)) (range))) ; chan [#(+ % 0) #(+ % 1) ...]
        (a/to-chan [1 2 3]))
;; => chan [1 3 5]
```

- [core.async/map](https://clojure.github.io/core.async/#clojure.core.async/map)
- [core.async/to-chan](https://clojure.github.io/core.async/#clojure.core.async/to-chan)

### Monad

A Monad is a container type with two functions: `(mreturn v)` acts just like `(pure v)`. `(mbind f mv)` binds a function of type `a -> Monad b` with a type `Monad a`. For channels, I believe this should act similar to lists, where bind will call `f` on each value in the list, and concatenate the results.

```clojure
;; Monad Laws
(= (f v) (bind f (return v)))
(= c (bind return c))
(= (bind #(bind g (f %)) c)
   (bind g (bind f c)))
```

<code data-gist-id="cf00fa7ed9259b9951ee" data-gist-line="84-93"></code>

`mreturn` is exactly `pure` (and has the same `::nil` shortcut).

`mbind` creates a comprehension of channel functions. We take an incoming channel of values `mv` and call `pipeline-async` that through the function `#(a/pipe (bindf %1) %2)`. `pipeline-async` allows us to call a function on each value of a channel asynchronously and put any number of values on the result channel. Here we call `f` using `bindf` (`bindf` is defined to allow channel monad transformers), and put all the values of the returned channel onto the `pipeline-async` channel.

This will allow usage of channel's `bind` for promise-like semantics as well as stream-like semantics. Here is a

```clojure
;; Promise-like usage of channel
;; mlet is cats version of do syntax, it is a macro that reduces to bind/return
(mlet [query (create-query) ; => query is eventually a string
       resp (http/get-request (str "http://google.com/?" query))]
  (return (:body resp)))
```

And here is an example of channel comprehension akin to list comprehension using the stream-like mechanics of `bind`.

```clojure
(mlet [a (a/to-chan [1 5])
       b (a/to-chan [a (* 2 a)])
       c (+ a b)]
  (return c))
;; => chan [2 3 10 15]
```

What's cool with `mlet` and channels is you can mix in `:when` and `:let` statements:

```clojure
(mlet [a (a/to-chan (range 1 10)
       :when (even? a)
       :let [b (* a 2)]]
  (return b)
;; => chan [4 8 12 16]
```

- [core.async/pipeline-async](https://clojure.github.io/core.async/#clojure.core.async/pipeline-async)
- [core.async/pipe](https://clojure.github.io/core.async/#clojure.core.async/pipe)
- [core.async/to-chan](https://clojure.github.io/core.async/#clojure.core.async/to-chan)

### MonadZero & MonadPlus

MonadZero and MonadPlus are ways to use the Monoid and Semigroup interfaces in a monad context. Their implementations therefore follow similarly.

<code data-gist-id="cf00fa7ed9259b9951ee" data-gist-line="95-101"></code>

### Monad Transformers

Monad transformers can be used with channel as the base monad. For instance, with the either monad:

```clojure
(require '[cats.monad.either :as e]
         '[cats.labs.channel :as [chan]]
         '[cats.context :as ctx])

(def chaneither-m (e/either-t chan/context))

(ctx/with-context chaneither-m
  (mlet [x (a/to-chan [(e/right 1)])
         y (a/to-chan [(e/right 2)])]
    (return (+ x y))))
;; chan [(right 3)]

(ctx/with-context chaneither-m
  (mlet [x (a/to-chan [(e/right 1)])
         y (a/to-chan [(e/left "error!")])]
    (return (+ x y))))
;; chan [(left "error!")]
```

## Conclusions

This post shows how some type theory protocols are implemented in `cats.labs.channel`. What's so cool about these implementations is they work together in a way to use these abstractions to perform both promise-style and stream-style processing. The Monad interface can be used to concatenate operations in a serial way. The MonadPlus and Semigroup operations can be used to concatenated streams of data in a parallel fashion. With Functor and Applicative, one can do synchronous transformations.

_Footnotes_:

- Recently, I submitted a [PR][cats-pr] to [cats][cats] containing the semantics below. ([follow-up PR][cats-pr-2])
- There are multiple possible semantics for `mappend` and `mbind`, but these are my preferred ones given how channels are used. See the [PR discussion][cats-pr].
- This implementation of `cats.labs.channel` is released as `[cats "1.3.0-SNAPSHOT"]`.


[csp]: https://en.wikipedia.org/wiki/Communicating_sequential_processes
[go-concurrency]: https://golang.org/doc/effective_go.html#concurrency
[core-async]: https://github.com/clojure/core.async
[green-threads]: https://en.wikipedia.org/wiki/Green_threads
[cats]: https://github.com/funcool/cats
[cats-pr]: https://github.com/funcool/cats/pull/136
[cats-pr-2]: https://github.com/funcool/cats/pull/139
