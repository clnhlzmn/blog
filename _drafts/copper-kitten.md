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

Another reason that I have been working on this project is to experiment with using higher level languages on constrained systems like 8-bit AVR microcontrollers. I use C to write code for such devices at work every day and I am often frustrated by the lack of a few key features such as:

* Automatic memory management

  On resource constrained platforms `malloc` and `free` are esentially forbidden because you can't gurantee that your app will always have enough memory when the heap becomes fragmented, and it is very hard to gurantee that you will call `free` in all the correct places. Automatic memory management can take care of both of these issues with the drawback of the need to stop your main app thread occasionally. Advanced automatic memory management systems have been designed that limit the drawbacks.

* First class functions

  These can be simulated in C using function pointers and a context parameter but it is awkward. 

* Compile time code generation (à la C++ templates)

  I think C++ is very interesting in this regard, but I believe it tries to do too much.

* A good way to write hierarchical state machines

#### How
