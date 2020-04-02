---
layout: post
title:  "Intrusive Linked Lists"
date:  2020-04-01 16:00:00 -0500
categories: programming
tags: [algorithms, data structures, C]
---

Everyone knows what a linked list is, right? It's simplest form à la Haskell:

```
data List a = nil | cons a (List a)
```

That is, a linked list containing elements of type `a` is either `nil` (empty) or it's a `cons` (a construct, or pair) of `a` and another `List a`. This is elegant, but it's not the kind of list we're talking about.

To a C programmer that probably doesn't mean a whole lot.
