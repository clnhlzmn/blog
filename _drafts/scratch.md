For the list type the compiler generates six functions:

* two constructors `nil: () List(A)` and `cons: (A, List(A)) List(A)`

    `a: A` means that idenifier `a` has type `A`

* two predicates `is_nil: (List(A)) Int` and `is_cons: (List(A)) Int` 

    no booleans for now: 0 is false, 1 is true

* and two accessors for the fields of cons `cons_0: (List(A)) A` and `cons_1: (List(A)) List(A)`