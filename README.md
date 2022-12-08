# An Interpreter for MiniOO 
This is an interpreter of a Mini Object-Oriented Language. The Project if for the personal project in HPL (2022-fall) by Jeffery Wang.
## Overview
![overview1](https://user-images.githubusercontent.com/98352935/206552548-10b8f656-4753-4b0d-a5e6-14cb7aaae926.svg)

## Syntax and Semantics of the MiniOO Language
The Syntax and Semantics of MiniOO are based on the MiniOO syntax&semantics in ./MiniOO.pdf with static scope. There are a few modifications for syntax (to avoid some ambiguity in parsing) and semantics (for a more straightforward implementation). 
* Modifications to Syntax
   * the keyword __end__ is added at the end of the procedure declaration:  proc y: C end
   * the keyword __then__ is added for if and while statement:if b then C else C
     -  __e.g. proc n: y = proc n: while 0<a then {a=a-1;x=x+1} end__
   * to distinguish variables and fields, the token for variable is, the token for variables starts with Lowercase letter whereas the token for fields start with Uppercase letter.
      -  __.g.var foo; foo = Foo -> this expression means foo is variable, and a field value Foo is assigned in it__
* Modifications to Semantics
   * whenever a object is allocated through malloc, only one field, "is_object" is created for the object, this "is_object" is never accessed and only indicate that the object has been created.
* Added feature
   * more arithmatic operator "+" and "*" is introduced. 
   * the parenthesis for expression introduced to prioritize  operations. 
       - __e.g. In x.y.z, x.y will be evaluated at first, while in x.(y.z), y.z will be evaluate at first__
   * printf(e), this will simply evaluate e and print its value to the print space.
  
  
  ## Details of code and the guide to use the interpreter 
  The interpreter is implemented purely in OCaml. The implementation details of the MiniOO interpreter are in the directory __./src__. The compile and link detail is in ./src/makefile. To compile and test the code, run __cd src__ and __make__.
