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

There are three built in types in CK: `Unit`, `Int`, and `Fun(A, ..., R)`. The first is the usual unit type with exactly one value. The second is a signed integer implemented by the C type `intptr_t`. That means its size depends on the target machine. The third type `Fun(A, ..., R)` is the function type where `A, ...` represents argument types and `R` is the return type. The function type can also be written as `(A, ...) R`.

Users can define their own types using a `type ...` declaration at the beginning of a CK file. For example the declaration `type List = (A) nil() | cons(A, List(A))` creates the type `List(A)` where `A` can be any type. For now, CK doesn't have pattern matching. To work with user defined type the compiler implements a number of functions behind the scenes. For the list type the compiler generates six functions: two constructors `nil: () List(A)` and `cons: (A, List(A)) List(A)` (`a: A` means that idenifier `a` has type `A`); two predicates `is_nil: (List(A)) Int` and `is_cons: (List(A)) Int`; and two accessors for the fields of cons `cons_0: (List(A)) A` and `cons_1: (List(A)) List(A)`. Pattern matching, when implemented, will use these functions behind the scenes. Until then the programmer can use them to construct instances of user defined types and access their fields.

A CK file, for now, consists of declarations followed by an expression. In the [grammar] there are two types of declaration, but for now only `typeDecl` is implemented. `moduleDecl` is a work in progress. The type declarations cause a number of functions to be implemented by the compiler for use in the following expression. The expression is treated as the entry point for the program. In the future I would like to add support for multiple files and perhaps separate compilation.

The grammar of expressions includes

* unit literal 

  `()`

* integer literals

  `0`, `1`, `1000000000000000`

* all the usual unary and binary operations on integers

* function applications 

  `id(42)`, `add(1, 2)`, `map(aList, (e) e * e)`

* function literals 

  `(a) a`, `(a, b) a + b`, `(n) n * n`

* two forms of conditional expression 

  `cond() ? true() : false()`, `if (cond()) true() else false()`, `if (cond()) true()`
  
  Conditional expressions must have expressions that evaluate to the same type for their consequents and alternates. An `if` without an else has type `Unit`.

* sequence expressions

  `{ a; b }`

* and let expressions 

  `let id = (a) a`, `let rec forever = (f) { f(); forever(f) }`

Note that the let expression doesn't include `in <expr>`. The scope of a let expression is the rest of the expressions in the enclosing sequence. That is `{let id = (a) a; id(42)}` is can be thought of as `let id = (a) a in id(42)`. Tuple and string literals are included in the [grammar], but they're not yet implemented.

Note that type annotations are not required. For clarity the programmer can annotate the types of let bound variables, functions parameters, and function return types using the `: T` syntax. For example `let id: (A) A = (a: A):A a`. Type annotations are not yet fully implemented, but it should be an easy feature to finish. At the moment there are not any reasons to add type annotations. I would like to add record types and corresponding syntax such as `a.b` which will, as far as I know, require minimal type annotations.

[code]: https://github.com/clnhlzmn/CopperKitten
[makefile]: https://github.com/clnhlzmn/CopperKitten/blob/master/example/simple/makefile
[simple_io.ck]: https://github.com/clnhlzmn/CopperKitten/blob/master/example/simple/simple_io.ck
[grammar]: https://github.com/clnhlzmn/CopperKitten/blob/master/compiler/ckc/grammar/ck.g4