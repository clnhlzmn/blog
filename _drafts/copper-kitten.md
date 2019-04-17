---
layout: post
title:  "CopperKitten"
date:  2019-04-13 13:30:00 -0500
categories: programming
tags: [languages, cs, design]
---

## Introduction

CopperKitten (CK) is an exercise in programming language and runtime design and implementation. Check out the [code].

This project is far from complete. It will probably never be fully complete. I have a few features that I would like to implement before I put it aside. I am writing this post to introduce what I have done so far and invite comments and discussion.

CK is a simple functional language with Hindley Milner type inference. Its compiler and assembler are currently implemented in Kotlin. The compiler ([ckc]), for now, compiles a single 'script' file to its corresponding portable assembly listing, and then the assembler ([cka]) assembles that listing to a portable C99 program. An example of this can be seen in the makefile [here][makefile]. Using the makefile requires java and gcc. The script [simple\_io.ck] is intended to illustrate features of the language that have been implemented so far.

## The Language

### Built-in Types

There are three built in types in CK: `Unit`, `Int`, and `Fun(A, ..., R)`. The first is the usual unit type with exactly one value. The second is a signed integer implemented by the C type `intptr_t`. That means its size depends on the target machine. The third type `Fun(A, ..., R)` is the function type where `A, ...` represents argument types and `R` is the return type. The function type can also be written as `(A, ...) R`.

### User Defined Types

Users can define their own types using a `type ...` declaration at the beginning of a CK file. For example the declaration `type List = (A) nil() | cons(A, List(A))` creates the type `List(A)` where `A` can be any type. For now, CK doesn't have pattern matching. To work with user defined type the compiler implements a number of functions behind the scenes. For the list type the compiler generates six functions: two constructors `nil: () List(A)` and `cons: (A, List(A)) List(A)` (`a: A` means that idenifier `a` has type `A`); two predicates `is_nil: (List(A)) Int` and `is_cons: (List(A)) Int` (no booleans for now: 0 is false, 1 is true); and two accessors for the fields of cons `cons_0: (List(A)) A` and `cons_1: (List(A)) List(A)`. Pattern matching, when implemented, will use these functions behind the scenes. Until then the programmer can use them to construct instances of user defined types and access their fields.

### CK Programs

For now a CK program consists of a single .ck file. A .ck file is zero or more declarations followed by zero or one expressions. Zero expressions in a .ck file is treated as if the single expression is `()` (unit). In the [grammar][ck.g4] there are two types of declaration, but for now only `typeDecl` is implemented. `moduleDecl` is a work in progress. The type declarations cause a number of functions to be implemented by the compiler for use in the following expression. The single expression in the .ck file is treated as the entry point for the program. In the future I would like to add support for multiple files and perhaps separate compilation.

### Expressions

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

### C Language Bindings

Another type of function expression is `cfun`. These can be used any place an ordinary function expression can be used. `cfun` is used to create a binding to a function defined in C for doing IO and whatever else you would rather do in C. In the [example][simple_io.ck] there are two `cfun` that are used to read and write characters on stdout and stdin respectively. A `cfun` looks like `cfun id Type` where `id` is the identifier that matches the identifier of the function in C and `Type` is the type of that function. The `native_read` and `native_write` functions are implemented [here][builtin_cfuns.c]. The file that defines the native functions must be compiled and linked with the output from ckc/cka (this is illustrated [here][makefile]).

## Implementation

The implementation of CK includes a compiler, assembler, and runtime.

### Compiler

The CK compiler ([ckc]) takes a single file (program.ck) and compiles it to a CK assembly file (program.cka). Compilation proceeds in a few steps:

1. Parse program.ck using ANTLR4.

   ANTLR4 generates the [classes][generated parser] required to parse a CK file based on the grammar [ck.g4].

2. Convert the ast that is produced by ANTLR to a simpler ast that is easier to work with.

   The class CkBaseVisitor (generated by ANTLR) is extended [here][grammar visitors] to convert the ANTLR generated ast into a [simpler representation][ast]. The CkBaseVisitor extensions are used to parse program.ck [here][parse.kt] and return an instance of BaseASTNode.

3. Type check the program.

   Type checking is implemented [here][analyze.kt]. The type checker (inferrer) is based on the example implementation at the end of ["Basic Polymorphic Typechecking" by Luca Cardelli][Cardelli].

4. Compile the program.

   Compilation is done by the [CompilationVisitor] class. For now this amounts to visiting the ast and returning a list of assembler instructions.

The [command line option interpreter][CLI] is the entry point for ckc. It parses command line options, reads the input file, performs the compilation steps above, and writes the output to the specified output file.

### Assembler

The CK assembler ([cka]) takes a single program.cka file (program) and converts it to a C99 program.c file that includes the CK program bytecode and the program entry point. The main task of the assembler is to convert the [abstract assembler syntax][cka.g4] into a list of concrete bytecodes and literal values to be consumed by the runtime vm. Part of cka's task is to generate layout functions to be used by the memory management scheme to identify pointers on the stack and in heap allocated objects.

I won't go into too much detail on cka here unless there is interest. It's pretty boring and mostly self explanatory.

The output of cka (program.c) must be compiled and linked with any files containing definitions of `cfun`s and with the chosen garbage collection implementation file (one of copying\_gc.c, incremental\_gc.c, or mark\_compact\_gc.c). Again, the example [makefile] demonstrates this.

### Runtime

The CK runtime is a simple bytecode interpreter combined with one of three tracing garbage collection implementations. I could have implemented CK by compiling directly to C, rather than using a vm, but I wanted to be able to support tail call optimization and I couldn't see how to do that in plain C.

#### VM

The CK vm is implemented by [vm.h]. Opcodes are enumerated in the type `enum vm_op_code` and are reasonably well documented there. In addition to the usual arithmetic operations there are some for control flow, stack frame management, memory allocation, storing/loading values to/from indices into heap objects/stack frames/function arguments/function captures, and some other miscellaneous operations. Program execution is done by the function `vm_execute` which simply iterates over the given program array dispatching on each op code.

#### Memory Management

There are two copying collectors (one incremental) and one mark compact. I hope they can be used as examples for people who are curious about how garbage collection works. The garbage collectors all depend on [gc\_interface.h] which declares a common set of functions with which the vm can interface with the heap memory.

## Future Work

Here is a list (in roughly the required order) of work that I would like to do on this project in the future.

* clean up, organize, and simplify: compiler, assembler, and runtime source files

* integrate programmer type annotations with type checker

* strings and tuples

* modules

* implement parser and CLI in Kotlin (removing ANTLR and Apache CLI dependencies)

* implement compiler and assembler in eager functional language like ML

* implement compiler and assembler in CK

* generate machine code rather than C99

* optimize polymorphic functions to not always use boxed types for integers

* lots of other optimizations

[code]: https://github.com/clnhlzmn/CopperKitten
[makefile]: https://github.com/clnhlzmn/CopperKitten/blob/master/example/simple/makefile
[simple_io.ck]: https://github.com/clnhlzmn/CopperKitten/blob/master/example/simple/simple_io.ck
[ck.g4]: https://github.com/clnhlzmn/CopperKitten/blob/master/compiler/ckc/grammar/ck.g4
[cka.g4]: https://github.com/clnhlzmn/CopperKitten/blob/master/compiler/cka/grammar/cka.g4
[builtin_cfuns.c]: https://github.com/clnhlzmn/CopperKitten/blob/master/runtime/builtin_cfuns.c
[ckc]: https://github.com/clnhlzmn/CopperKitten/blob/master/compiler/ckc/
[cka]: https://github.com/clnhlzmn/CopperKitten/blob/master/compiler/cka/
[generated parser]: https://github.com/clnhlzmn/CopperKitten/blob/master/compiler/ckc/gen/
[grammar visitors]: https://github.com/clnhlzmn/CopperKitten/blob/master/compiler/ckc/src/ck/grammar/visitors
[ast]: https://github.com/clnhlzmn/CopperKitten/blob/master/compiler/ckc/src/ck/ast/node/
[parse.kt]: https://github.com/clnhlzmn/CopperKitten/blob/master/compiler/ckc/src/ck/grammar/Parse.kt
[analyze.kt]: https://github.com/clnhlzmn/CopperKitten/blob/master/compiler/ckc/src/ck/analyze/Analyze.kt
[Cardelli]: http://lucacardelli.name/Papers/BasicTypechecking.pdf
[CompilationVisitor]: https://github.com/clnhlzmn/CopperKitten/blob/master/compiler/ckc/src/ck/ast/visitors/CompilationVisitor.kt
[CLI]: https://github.com/clnhlzmn/CopperKitten/blob/master/compiler/ckc/src/ck/Cli.kt
[vm.h]: https://github.com/clnhlzmn/CopperKitten/blob/master/runtime/vm.h
[gc_interface.h]: https://github.com/clnhlzmn/CopperKitten/blob/master/runtime/gc_interface.h