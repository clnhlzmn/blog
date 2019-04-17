---
layout: post
title:  "CopperKitten"
date:  2019-04-13 13:30:00 -0500
categories: programming
tags: [languages, cs, design]
---

### Introduction

CopperKitten (CK) is an exercise in programming language and runtime design and implementation. Check out the [code].

This project is far from complete. It will probably never be fully complete. I have a few features that I would like to implement before I put it aside. I am writing this post to introduce what I have done so far and invite comments and discussion.

CK is a simple functional language with Hindley Milner type inference. Its compiler and assembler are currently implemented in Kotlin. The compiler (ckc), for now, compiles a single 'script' file to its corresponding portable assembly listing, and then the assembler (cka) compiles that listing to a portable C99 program. An example of this can be seen in the makefile [here][makefile]. Using the makefile requires java and gcc. The script [simple\_io.ck] is intended to illustrate features of the language that have been implemented so far.

### The Language

There are three built in types in CK: `Unit`, `Int`, and `Fun(A, ..., R)`. The first is the usual unit type with exactly one value. The second is a signed integer implemented by the C type `intptr_t`. That means its size depends on the target machine. The third type `Fun(A, ..., R)` is the function type where `A, ...` represents argument types and `R` is the return type. The function type can also be written as `(A, ...) R`.

Users can define their own types using a `type ...` declaration at the beginning of a CK file. For example the declaration `type List = (A) nil() | cons(A, List(A))` creates the type `List(A)` where `A` can be any type. For now, CK doesn't have pattern matching. To work with user defined type the compiler implements a number of functions behind the scenes. For the list type the compiler generates six functions: two constructors `nil: () List(A)` and `cons: (A, List(A)) List(A)` (`a: A` means that idenifier `a` has type `A`); two predicates `is_nil: (List(A)) Int` and `is_cons: (List(A)) Int` (no booleans for now: 0 is false, 1 is true); and two accessors for the fields of cons `cons_0: (List(A)) A` and `cons_1: (List(A)) List(A)`. Pattern matching, when implemented, will use these functions behind the scenes. Until then the programmer can use them to construct instances of user defined types and access their fields.

A CK file, for now, consists of declarations followed by an expression. In the [grammar] there are two types of declaration, but for now only `typeDecl` is implemented. `moduleDecl` is a work in progress. The type declarations cause a number of functions to be implemented by the compiler for use in the following expression. The expression is treated as the entry point for the program. In the future I would like to add support for multiple files and perhaps separate compilation.

The grammar of expressions includes

* unit literal 

  `()`

* integers

  `0`, `1`, `1000000000000000`

* all the usual unary and binary operations on integers

  `a + b`, `-42`, `a || (b <> c)`

  All unary and binary operators take arguments of type `Int` and return values of type `Int`

* function applications 

  `id(42)`, `add(1, 2)`, `map(aList, (e) e * e)`

  CK uses eager evaluation.

* function 

  `(a) a`, `(a, b) a + b`, `(n) n * n`

  CK supports limited tail call optimization. For a function call in tail position, if the callee has the same number of arguments as the caller, then the stack frame is reused, otherwise the call will create a new stack frame.

* two forms of conditional expression 

  `cond() ? true() : false()`
  
  `if (cond()) true() else false()`
  
  `if (cond()) true()`
  
  Consequent and alternate expressions of a conditional expression must have the same type. An `if` without an `else` has type `Unit` (that means the consequent must have type `Unit`). Condition expressions must have type `Int` where 0 is false and 1 is true, for now. I intend to add a true boolean type at some point.

* sequence expressions

  `{ a; b }`

  `a` is evaluated and its result discarded, then `b` is evaluated and its value is the value of `{ a; b }`.

* and let expressions 

  `let id = (a) a`, `let rec forever = (f) { f(); forever(f) }`, `{ let id = (a) a; id(42) }`

  The scope of a let expression is the rest of the expressions in the enclosing sequence. That is `{let id = (a) a; id(42)}` can be thought of as `let id = (a) a in id(42)`. 

* Tuples and strings are included in the grammar, but they're not yet implemented.

Note that type annotations are not required. For clarity the programmer can annotate the types of let bound variables, functions parameters, and function return types using the `: T` syntax. For example `let id: (A) A = (a: A):A a`. Type annotations are not yet fully implemented, but it should be an easy feature to finish. At the moment there are not any situations that _require_ annotations. I would like to add record types and corresponding syntax such as `a.b` which will, as far as I know, require limited type annotations.

Another type of function literal expression is `cfun`. This is used to create a binding to a function defined in C for doing IO and whatever else you would rather do in C. In the [example][simple_io.ck] there are two `cfun` defined at the top that are used to read and write characters on stdout and stdin respectively. A `cfun` looks like `cfun id Type` where `id` is the identifier that matches the identifier of the function in C and `Type` is the type of that function. The `native_read` and `native_write` functions are implemented [here][builtin_cfuns.c]. The file that defines the native functions must be compiled and linked with the output from ckc/cka (this is illustrated [here][makefile]).

### Implementation



### Future Work



[code]: https://github.com/clnhlzmn/CopperKitten
[makefile]: https://github.com/clnhlzmn/CopperKitten/blob/master/example/simple/makefile
[simple_io.ck]: https://github.com/clnhlzmn/CopperKitten/blob/master/example/simple/simple_io.ck
[grammar]: https://github.com/clnhlzmn/CopperKitten/blob/master/compiler/ckc/grammar/ck.g4
[builtin_cfuns.c]: https://github.com/clnhlzmn/CopperKitten/blob/master/runtime/builtin_cfuns.c