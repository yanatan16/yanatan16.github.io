---
layout: post
section: index
title: Common Type Theory Abstractions
date: 2015-12-29 10:00:00
categories: type-theory
---

Monads scare a lot of programmers. A) Its a weird word. B) A lot of academic ass holes use it to feel superior. I'd like to change that. So here's my guide to three common type theory abstractions: Monoids, Functors, and Monads. I hope to help you understand these type abstractions by looking at types you already use in programming. This guide is aimed at programmers familiar with functional programming.

<!--break-->

**Disclaimer**: I am not a type theorist. This guide is not written in the style of a mathematics class. It is instead aimed to help those not familiar with abstract mathematics become familiar with constructs they can use to help them.

## Abstractions

Abstractions are key to writing any complex program. Human brains cannot handle the amount of knowledge required to program in today's world without abstractions. These abstractions allow a programmer to think on a "higher level." Take `jQuery`, for instance, which provides `$.ajax()` to perform an HTTP AJAX request from the browser. A programmer doesn't have to consider each browser's implementation of AJAX, just what his or her app needs in the HTTP request.

The type theory abstractions below are each defined as a "typeclass" or "interface" that different concrete types implement. Each type can implement the typeclass with different functionality, but they all satisfy the "laws" or "rules" of that abstraction. This allows programmers to decouple their code from concrete types and instead couple with one or more type abstractions.


## Notation

I will be using Haskell-style type syntax. It looks like this:

```haskell
-- fn0 is a function of zero arguments returning a type a
fn0 :: a

-- fn1 is a function of 1 argument of type a and returns type b
fn1 :: a -> b

-- fn2 is a function of two integers, returning a string
fn2 :: Integer -> Integer -> String

-- fn3 is (a c) -> b, where a is a type function with c as its argument
-- type functions are like container types, such as Array<C> in Java
fn3 :: (a c) -> b

-- fn4 is like fn3 but a must be a monad (i.e. must satisfy the typeclass/interface)
fn4 :: (Monad a) => (a c) -> b

-- fn5 takes a function as an argument and calls it with 0
fn5 :: (Integer -> Integer) -> Integer
fn5 f = f 0

-- fn6 calls map with an increment (as an anonymous function) on an array
fn6 :: Array Integer -> Array Integer
fn6 arr = map (\x -> x + 1) arr

-- MyEquality is a typeclass (interface) that has some functions
class MyEquality a where
  equals :: a -> a -> Bool

-- SomeType is implementing the typeclass MyEquality
-- here the function name is equals, x and y are arguments
-- the body of the function is after the first equal sign
instance MyEquality SomeType where
  equals x y = (x == y)
```

## Monoids

A monoid is a typeclass that has a "zero" and can be appended. It must implement two functions:

```haskell
class Monoid a where
  mempty :: a
  mappend :: a -> a -> a

-- Monoid laws:
-- mempty is an identity
mappend x (mempty) = x
mappend (mempty) y = y
-- Associativity
mappend x (mappend y z) = mappend (mappend x y) z
```

The `mappend` function combines two instance of a monoid and returns another instance of it. We do this all the time in programming. There are so many structures in programming that implement this interface: lists, arrays, sets, numbers, maps. Let's implement a couple for example:

```haskell
class Monoid Integer where
  mempty = 0
  mappend x y = x + y

class Monoid (List a) where
  mempty = []
  mappend x y = concat x y
```

So why is this type useful? Why wouldn't a programmer just use `+`, `concat`, or `merge`, as appropriate for the type in question?

First, the `reduce` function does very similar work to this. Its type signature is:

```haskell
reduce :: (a -> b -> a) -> a -> [b] -> a
```

What if we redefined reductions with monoids?

```haskell
-- reduceMonoid is often called msum
reduceMonoid :: (Monoid a) => [a] -> a
```

Hey, `reduceMonoid` looks a lot like List's `flatten` and Integer's `sum` doesn't it? Thats because those two functions are just monoid summations from a list of values.

Ok, we established that monoids (and monoid reductions) are used all the time, but still, why wouldn't I use the appropriate function for the appropriate type?

The answer comes when creating container types, that is, types that contain other types. A common type container is the `Maybe a` type, which either contains a value of type `a`, or nothing. This is sometimes called `Optional` (Java 8 and Swift have `Optional<A>`).

```haskell
-- (Maybe a) is a haskell type with possible values Nothing, or (Just v)
-- where v is of type a.
type Maybe a = Nothing | Just a

instance (Monoid a) => Monoid (Maybe a) where
  mempty = Just (mempty)
  mappend x y = case (x,y) in
                 (Nothing, y) -> y
                 (x, Nothing) -> x
                 (Just x, Just y) -> Just (mappend x y)
```

Here, we see how we can use the monoid functions on a type `Maybe a`, only when the inner type `a` is a monoid type. In Java 8 lingo, this means that `Optional<List<A>>` can be appended to because it wraps a type that can be appended to.

## Functors

A functor is a very simple container type with one function:

```haskell
class Functor f where
  fmap :: (a -> b) -> f a -> f b

-- Functor laws
fmap identity x = x
fmap (compose f g) x = fmap f (fmap g x)
```

Functors are any container type where a programmer can manipulate the value _inside_ the container. The most common example is the list's map function:

```haskell
instance Functor List where
  fmap f x = map f x
```

This abstraction, however simple, is very powerful. Consider the following node.js code:

```node
function asyncFmap(someAsyncCall, someMappingFunction, callback) {
  someAsyncCall(function (err, val) {
    if (err)
      callback(err)
    else
      callback(null, someMappingFunction(val))
  })
}

function promiseFmap(promise, someMappingFunction) {
  return promise.thenSync(someMappingFunction)
}
```

This is a very common action in node.js, mapping a future value using callbacks. Then we've shown the same action using promises. A promise is a container type, which allows access to the value inside it. Therefor a promise is a Functor, and the `thenSync` function is its `fmap`!

Again, you might ask, why would I use `fmap()` instead of `.thenSync()` or `map()`? The Functor abstraction is so simple that it is trivial for many types ot implement. As soon as I see some new type is a Functor, I immediately know how it acts under the functor laws, and that I can then pass it into any of my code that handles functors (and not just a specific functor such as a list).

All the container-like structures are functors, such a lists, sets, and maps; but also trees, and graphs. Promises and streams are functors too. That means that synchronous code meant for lists can be applied to asynchronous streams of data. Also, any monad talked about in the next section is also a functor.

## Monads

Monads are a lot like [Functors](#functors): they contain a type and allow the programmer to manipulate the type inside in a certain way. But they allow a more complicated version of inner manipulation to happen. Instead of going straight to type signatures, lets check out a couple monads.

I introduced the `Maybe` (aka `Optional`) type earlier. Here's some functions that are useful with the `Maybe` type:

```haskell
-- createMaybe constructs a maybe type with value (Just v)
createMaybe :: a -> Maybe a
createMaybe x = Just x

-- step is a function to be used in a set of computational steps
-- step takes a current value `v :: Maybe a` and a function `f :: a -> Maybe b`
-- If v is Nothing, step returns Nothing
-- If v is (Just x), step returns (f x)
step :: Maybe a -> (a -> Maybe b) -> Maybe b
step Nothing _ = Nothing
step (Just x) f = f x

-- myComputation does a 3 step computation using the maybe step function
myComputation = let s0 = createMaybe 0
                    s1 = step s0 step1Computation
                    s2 = step s1 step2Computation
                    s3 = step s2 step3Computation
                in s3
```

This seems to be a reasonable way to create a 3-step computation where any one step might fail. Now lets consider a similar example with promises:

```haskell
-- createPromise constructs a promise type with a value resolved inide of it
createPromise :: a -> Promise a
createPromise x = Resolved x

-- thenAsync is the asynchronous version of thenSync
thenAsync :: Promise a -> (a -> Promise b) -> Promise b

asyncComputation = let s0 = createPromise "http://google.com"
                       s1 = thenAsync s0 step1AsyncComputation
                       s2 = thenAsync s1 step2AsyncComputation
                       s3 = thenAsync s2 step3AsyncComputation
                   in s3
```

This _also_ seems like a reasonable way to construct a 3-step serial asynchonous task. Perhaps we can abstract this functionality into a common typeclass.

```haskell
class Monad m where
  return :: a -> m a
  bind :: m a -> (a -> m b) -> m b

-- Monad Laws:
bind (return a) f = f a
bind m return = m
bind (bind m k) h = bind m (\x -> bind (k x) h)
```

A monad is a container type that implements two functions:

- `return` creates a monad type wrapping the value given
- `bind` takes a current monad value and a function of that inner value to a new monad value and returns a new monad value.

The `bind` function can be hard to visualize, so think of its examples:

- The `Promise`'s `thenAsync` function to serially append an async computation
- The `Maybe`'s `step` function (defined above) to continue calculation only if `Nothing` has not been encountered
- The `List`'s `flatMap` function, which maps values to lists and concatenates them (aka list comprehension)

Once you understand how a particular monad implements `bind`, you can use it with higher-level functions that call the `return` and `bind` functions insde them. One of those is `do`-notation, which allows one to write imperative-looking monad bind statements simply, leveraging the power of the underlying monad. I won't cover `do`-notation here, but if you are interested, search it out.

## Combining Types

I want to point out something about Functor and Monad. Here are the type signatures of `fmap`, `bind`, and for clarity `bindFlipped`:

```haskell
bind :: m a -> (a -> m b) -> m b

-- Bind with arguments flipped
bindFlipped :: (a -> m b) -> m a -> m b

fmap :: (a -> b) -> f a -> f b
```

Look how _similar_ the type signatures of `bindFlipped` and `fmap` are. They are both functions that allow manipulation of their inner values. In fact, any monad can implement `fmap` using `bind` and `return`:

```haskell
fmap f m = bind m (\x -> return (f x))
```

Think of the Promise type: `thenSync` is `fmap` and `thenAsync` is bind. Using these two abstractions, we can represent both synchronous and asynchronous serial computations in this way.

But what about asynchronous _parallel_ computations? If we cannot represent all the actions on a type using common type-theory abstractions, then the facade of abstractions break down. This is where monoid comes into play. We can use the monoid typeclass to wait on multiple promises in parallel, and combine them using the inner type's monoid implementation.

Here's the full specification of the typeclasses of Promise (with no implementation).

```haskell
type Promise a = Resolved a | Future

instance Functor Promise where
  fmap f p = thenSync p f

instance Monad Promise where
  return x = Resolved a
  bind p f = thenAsync p f

instance (Monoid a) => Monoid (Promise a) where
  mempty = Resolved (mempty)
  mappend p1 p2 = thenSync (waitForAll [p1, p2]) (\[v1, v2] -> mappend v1 v2)
```

## Conclusion

I hope you're convinced that these abstractions are in fact, not very complicated. As we've seen, types that implement these abstractions show up a lot in programming.

However, you may not be convinced that they are useful abstractions. I encourage you to start to view the types you use every day as implementing different these different patterns. When you start to see the world in this way, you can create your own abstractions that are decoupled from individual types, and instead operate on these abstractions detailed here.

## Using Monads


Here are some implementations of algebraic structures in your language:

- Clojure [cats](http://funcool.github.io/cats/latest/#introduction)
- Javascript [fantasyland](https://github.com/fantasyland/fantasy-land)
- Scala [scalaz](https://github.com/scalaz/scalaz) (with an [fistful of monads](http://eed3si9n.com/learning-scalaz/Monad.html))
- Haskell [Control.Monad](https://hackage.haskell.org/package/base-4.8.1.0/docs/Control-Monad.html) (the original [fistful of monads](http://learnyouahaskell.com/a-fistful-of-monads))


[nanoajax]: https://github.com/yanatan16/nanoajax nanajax: an ajax library you need a microscope to see
