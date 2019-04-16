---
layout: post
title:  "CopperKitten"
date:  2019-04-13 13:30:00 -0500
categories: programming
tags: [languages, cs, design]
---

CopperKitten (CK) is an exercise in programming language and runtime design and implementation. Check out the [code].

This project is far from complete. It will probably never be fully complete. I have a few features that I would like to implement before I put it aside. I am writing this post to introduce what I have done so far and invite comments and discussion.

CK is a simple functional language with Hindley Milner type inference. Its compiler and assembler are currently implemented in Kotlin. The compiler (ckc), for now, compiles a single 'script' file to its corresponding portable assembly listing, and then the assembler (cka) compiles that listing to a portable C99 program. An example of this can be seen in the makefile [here][makefile]. Using the makefile requires java and gcc. The script [simple\_io.ck] is intended to illustrate features of the language that have been implemented so far.

There are two built in types in CK: `Int` and `Fun(A, ..., R)`. The first is a signed integer implemented by the C type `intptr_t`. That means its size depends on the target machine. The second type `Fun(A, ..., R)` is the function type where `A, ...` represents argument types and `R` is the return type. The function type can also be written as `(A, ...) R`.

Users can define their own types using a `type ...` declaration at the beginning of a CK file. For example the declaration `type List = (A) nil() | cons(A, List(A))` creates the type `List(A)` where `A` can be any type. For now, CK doesn't have pattern matching. To work with user defined type the compiler implements a number of functions behind the scenes. For the list type the compiler generates six functions: two constructors `nil: () List(A)` and `cons: (A, List(A)) List(A)` (`a: A` means that idenifier `a` has type `A`); two predicates `is_nil: (List(A)) Int` and `is_cons: (List(A)) Int`; and two accessors for the fields of cons `cons_0: (List(A)) A` and `cons_1: (List(A)) List(A)`. Pattern matching, when implemented, will use these functions behind the scenes. Until then the programmer can use them to construct instances of user defined types and access their fields.

A CK file, for now, consists of declarations followed by an expression. In the [grammar] there are two types of declaration, but for now only `typeDecl` is implemented. `moduleDecl` is a work in progress. The type declarations cause a number of functions to be implemented by the compiler for use in the following expression. The expression is treated as the entry point for the program. In the future I would like to add support for multiple files and perhaps separate compilation.

The grammar for expressions includes literals such as `0`

[code]: https://github.com/clnhlzmn/CopperKitten
[makefile]: https://github.com/clnhlzmn/CopperKitten/blob/master/example/simple/makefile
[simple_io.ck]: https://github.com/clnhlzmn/CopperKitten/blob/master/example/simple/simple_io.ck
[grammar]: https://github.com/clnhlzmn/CopperKitten/blob/master/compiler/ckc/grammar/ck.g4