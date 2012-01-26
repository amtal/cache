```
"almost all programming can be viewed as an exercise in caching"
    -- Terje Mathisen
```

High performance systems cache extensively. In Erlang, the common pattern is to
introduce an ETS table storing function results, with a supervised process
doing periodic garbage collection. 

This approach has problems I seek to solve. They complicate testing, introduce
bugs, and make liberal caching less appealing:

* GC policy is adhoc and re-implemented from scratch every time.
* Complicated ETS side effects are interleaved with unrelated code.
* A supervision tree dependency is introduced.


Usage
=====

Wrap the thing you want to cache in a fun, and pass it to a wrapper specifying
cache type and a unique cache name.

```erlang
foo(A_,B_,C_) ->
    cache:this(cache_lru, myapp_mymod_foo, {A_,B_,C_}, fun({A,B,C})->
        '...'
    end).
```

Ideally your function should be referentially transparent: for a given set of
arguments, it should always give the same result. 

If that's the case, the wrapper is completely transparent, and does not change
the behaviour of the function. Unit tests, and partially started systems are
unaffected!

To speed up duplicate calls, start a process from somewhere meaningful in your
supervision tree. Pass the same policy

```erlang
{cache, start_link, [myapp_mymod_foo,60*?SECONDS,cache_lru,1000]}
```


Installation
============

To postpone rebar dependency hell, the library checks for dependencies but does
not autofetch specific versions. Add something like the following to 'deps' in
your rebar.config:

```erlang
{cache,    ".*",{git,"git://github.com/amtal/cache.git",    {tag,"v0.0.0"}}},
{lfe_utils,".*",{git,"git://github.com/amtal/lfe_utils.git",{tag,"v0.5.0"}}},
{lfe,      ".*",{git,"git://github.com/rvirding/lfe.git",   {tag,"v0.7a"}}},
```


Cache Policies
==============

Todo - I'm thinking LRU, and maybe fixed forward lookahead to start? Yeah, one
for spacial and one for temporal locality.


TODO
====

Add a [] option to cache:this that allows stats tracking to be turned on. Hit
ratio and maybe some GC stuff, in particular.


Terminology
===========

This is really a memoization library, but I'm going for mass appeal so I used a
friendly name.
