# An Interpreter for MiniOO 
This is an interpreter of a Mini Object-Oriented Language. The Project if for the personal project in HPL (2022-fall) by.  
Jeffery Wang  
email: jefferywcg@gmail.com
## Overview
![overview1](https://user-images.githubusercontent.com/98352935/206552548-10b8f656-4753-4b0d-a5e6-14cb7aaae926.svg)

## Syntax and Semantics of the MiniOO Language
The Syntax and Semantics of MiniOO are based on the MiniOO syntax&semantics in ./MiniOO.pdf with static scope. There are a few modifications for syntax (to avoid some ambiguity in parsing) and semantics (for a more straightforward implementation). 
* Modifications to Syntax
   * the keyword __end__ is added at the end of the procedure declaration:  proc y: C end
   * the keyword __then__ is added for if and while statement:if b then C else C
     -  __e.g.__ ```proc n: y = proc n: while 0<a then {a=a-1;x=x+1} end```
   * to distinguish variables and fields, the token for variable is, the token for variables starts with Lowercase letter whereas the token for fields start with Uppercase letter.
      -  __e.g.__  ```var foo; foo = Foo``` -> this expression means foo is variable, and a field value Foo is assigned in it
* Modifications to Semantics
   * whenever a object is allocated through malloc, only one field, "is_object" is created for the object, this "is_object" is never accessed and only indicate that the object has been created. When non-existent field is accessed, it is evaluated to Error. 
* Added feature
   * more arithmatic operator "+" and "*" is introduced. 
   * the parenthesis for expression introduced to prioritize  operations. 
       - __e.g.__ In ```x.y.z```, x.y will be evaluated at first, while in ```x.(y.z)```, y.z will be evaluate at first
   * ```printf(e)```, this will simply evaluate e and print its value to the print space. The domain of ```printf(e)``` is all __tva__ including Error.
  
  
  ## Details of code and the guide to use the interpreter 
  The interpreter is implemented purely in OCaml. The implementation details of the MiniOO interpreter are in the directory __./src__. The compile and link detail is in ./src/makefile. To compile and test the code, run ```cd src``` and ```make```. 
The environment for the interpreter includes ocamlc, menhir, and ocamllex.
* Here are a list of brief descriptions of each files inside __./src__ directory.
    * ```AST.ml``` - includs the data structures and contructors for the Abstract Syntax Tree
    * ```Lexer.mll``` - defines the lexer for recognizing tokens
    * ```Parser.mly``` - defines the context-free Grammer for parsing
    * ```Decoration.mly``` - includs functions for construction of decorated AST, including getting symbol tables and, checking scope, printing decorated AST
    * ```Demain.ml``` - defines the semantics domain, and helper functions for semantic transitions
    * ```Transition.ml``` - includes functions for small-step semantic transitions, evaluation of expression and bool expression.
    * ```Interpreter.ml``` - is the actually computing place for the program, it will iteratively do the small-step semantic transitions until termination, and print the results. 

* To write the program and run it with the interpreter 
  * replace the content ```./user.txt``` with user-supplied code, then run the scripts ```./run.sh``` or ```./run.sh -m```.  
  * there are two different trace modes for the interpreter, one includes the ```-m``` flag one without.
     - try ```./run``` to run trace mode 0 where the trace only include the AST, things that is explicitly printed by ```printf```,the stack and heap upon termination (the stack is meant to be empty if the program terminate without error). 
     - try ```./run -m``` to run trace mode 1 that will print a complete trace include the configuration and the __cumulative print space__ for each step. of semantic transition 
    
## Test cases and traces specification of Interpreter
### Test cases
There have been already 13 tests divided into 6 catagories aim to test the the correctness of interpreter in a comprehensive way. The test code and code specification of these 13 tests is in ```./tests/tests_get_trace``` and traces are saved in ```./tests/trace```. These tests are designed to cover all aspects of the features in miniOO. However there are not perfectly draconian and the user should feel free to write their own tests. 
* Here are a brief specification of each tests 
  * arithmatic tests
    - ```arithmatic_test1``` - compute the result of (1+(2+3)*2) and print it. It eventually prints 11 in the __cumulative print space__
  * control flow tests
    - ```ctlFlow_test1``` - iteratively compute the sum from 1 to 15 and stored it to variable ```z```. Eventually ```z.val``` will be 120
    - ```ctlFlow_test2``` - aims to do the same thing as test1, but in a tail recursive way
    - ```ctlFlow_test3``` - print 1 to 10, then print 10 to 1 by recursion. The __cumulative print space__ should be ``` 1  2  3  4  5  6  7  8  9  10  10  9  8  7  6  5  4  3  2  1``` upon termination
   * field expression and assignment tests
     - ```field_test1``` - create objects  x,y,z and compute the sum of x."FOO"+ y."FOO", then store it to z."Foo" and print it.
     - ```field_test2``` - does a nested field assignment and to assign ```x.Foo.Foo.Foo = 10```, then print it. 
   * parallelism tests
     - ```parallel_test1``` - creates two interleaving control flow of race condition on variable x, the result print(x) is non-deterministic
     - ```parallel_test2``` - creates a race condition on variable x, However, the operation is mutative(idempotent), so eventually print(x) will print 15
     - ```parallel_test3``` - tests atomic, similar to test 1 but both control flow is atomic the result print(x) is either "110 000 000 000" or "10 000 000 010"
    * scope error tests
      - ```scope_error_test1``` - tests scope error by using variable not decline
      - ```scope_error_test2``` - tests scope error by using variable declared but not in scope
     * run-time error tests
      - ```runtime_error_test1``` - assign(access) a field of a non-Object variable
      - ```runtime_error_test2``` - assign a non-assigned field of a Object to a variable 
