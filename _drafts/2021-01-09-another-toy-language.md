---
layout: post
title:  "Another Toy Language"
date:  2021-01-09 -0500
categories: programming
tags: [languages, cs, design]
---

I have been working on another toy language (one of the last being [CopperKitten](/2019/04/17/copper-kitten)). This new language started with the goal of implementing something like JavaScript's `async`/`await` using [protothreads](http://dunkels.com/adam/pt/) for small microcontrollers like AVR. That was interesting, and I was able to make it work, to some degree, but I decided to tear that up and go in a different direction. I would like to explore the `async`/`await` direction again later.

The goals for (language name) are to experiment with providing high level language features like first class functions with lexical closures and memory safety while targeting small microcontrollers that can't use an unpredictable garbage collector or even traditional memory management such as `malloc`/`free`.

In order to meet those goals (language name) provides automatic memory management in the form of automatic reference counting. Reference counting has some advantages, such as predictable behavior, when compared to tracing garbage collection. Furthermore, allocation is limited to fixed size blocks to eliminate fragmentation. This means that (language name) can run on systems with very little memory and under real time requirements while still providing those high level features.
