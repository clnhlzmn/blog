---
layout: post
title:  "CopperKitten"
date:  2019-04-13 13:30:00 -0500
categories: programming
tags: [languages, cs, design]
---

### Introduction

#### What

An exercise in programming language and runtime design and implementation.

#### Why

The first reason is that I have been fascinated with programming languages for as long as I have been programming. To better understand them I have built a few toy languages as a hobby. I think designing and implementing programming languages is a worthwhile pursuit for anyone who is trying to become a better programmer or who wishes to better understand how computers work. CopperKitten is the latest of my toy languages.

Another reason that I have been working on this project is to experiment with using higher level languages on constrained systems like 8-bit AVR microcontrollers. I write C code for such devices at work every day and I am often frustrated by the lack of a few key features such as:

* Automatic memory management

  On resource constrained platforms `malloc` and `free` are esentially forbidden because you can't gurantee that your app will always have enough memory when the heap becomes fragmented, and it is very hard to gurantee that you will call `free` in all the correct places. Automatic memory management can take care of both of these issues with the drawback of the need to stop your main app thread occasionally. Advanced automatic memory management systems have been designed that limit the drawbacks.

* First class functions

  These can be simulated in C using function pointers and a context parameter but it is awkward.

* Strong static type checking

  C has static type checking, but it's certainly not strong. I am in the camp that the compiler should do as much as possible to help the programmer write correct programs. Strong static type checking, augmented with some degree of type inference, is something that makes programming a lot more pleasant (in many cases (in my opinion)).

* Compile time code generation (à la C++ templates)

  C++ can do a lot in this regard, but I believe it tries to do too much.

* Hierarchical state machine library

  It seems that every program I write for small microcontrollers includes some kind of state machine. Simple state machines are easy to implement using a switch statement over a state variable. Even moderately more complex state machines benefit greatly from the concept of hierarchical states. Implementing hierarchical state machines by hand (using switch or function pointers) is challenging enough to negate the benefit of a state machine in the first place. What I would love is a library implemented in C that can produce hierarchical state machine implementations in a way that minimizes boilerplate and eliminates code duplication. The features I have listed above would help with this task.

These features aren't included in C because some of them necessarily abstract the hardware away from the programmer, are costly to implement, and or have a negative impact on performace. I am pointing out the lack of these features in C because C is the defacto standard language for embedded systems. Why should embedded programmers go without these things though? One reason that embedded programmers must go without is because the resources simply aren't available. In those situations, of course, C is the only choice.

#### How

* Automatic memory management

  This was the first feature of my wish list that I implemented for this project. I started with a simple copying collector in the style of [Cheney](https://en.wikipedia.org/wiki/Cheney%27s_algorithm). I added a mark compact collector and an incremental copying collector.

* First class functions

* Strong static type checking

* Compile time code generation (à la C++ templates)

* Hierarchical state machine library
