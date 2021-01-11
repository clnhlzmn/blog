---
layout: post
title:  "Another Toy Language"
date:  2021-01-09 -0500
categories: programming
tags: [languages, cs, design]
---

I have been working on another toy language (one of the last being [CopperKitten](/2019/04/17/copper-kitten)). This new language started with the goal of implementing something like JavaScript's `async`/`await` using [protothreads](http://dunkels.com/adam/pt/) for small microcontrollers like AVR. That was interesting, and I was able to make it work, to some degree, but I decided to tear that up and go in a different direction. I would like to explore the `async`/`await` direction again later.

The goals for (language name) are to experiment with providing high level language features like first class functions with lexical closures and memory safety while targeting small microcontrollers that can't use an unpredictable garbage collector or even traditional memory management such as `malloc`/`free`.

In order to meet those goals (language name) provides automatic memory management in the form of automatic reference counting. Reference counting has the advantage of predictable behavior when compared to tracing garbage collection. Furthermore, allocation is limited to fixed size blocks to eliminate fragmentation.

(language name) is like a Lisp in that everything is a list. All heap objects are lists anyway. The allocator allocates pairs of pointer sized objects. The pairs are used to create singly linked lists of the required number of elements. For example a tuple (`(1, 2)`) in (lanugage name) is represented as a list with 4 elements. Every heap object requires at least two elements. The first stores the reference count(s) and the second stores a pointer to the object's deinit function. In the case of the example (`(1, 2)`) the layout would look like: 

```
[<counts>|*]
        |--->[<deinit>|*]
                     |--->[1|*]
                             |--->[2|NULL]
```

This has some obvious disadvantages. To store 2 pointer sized objects (the integers 1 and 2) a total of 8 pointer sized objects are required. Also, to look at the value of an element of an object a number of pointers must be followed to reach the relevent element in the list.
