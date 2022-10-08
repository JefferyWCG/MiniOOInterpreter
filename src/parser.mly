/* File parser.mly */

%{

open AST

%} /* declarations */
%token <string >VARidt  FLD/* variable with an identifier (string)*/

(*key words and symbol tokens*)

%token <int> INT 
%token <bool> TorF  //    true/false 
%token  LESSTHAN 
//       ==       >       <      >=    <=   <>

%token EQL MINUS LPAREN RPAREN SEMICOLON COLON DOT  EOF  LBRACKET RBRACKET
//      =   +     -     *    /    (      )        ;       :    .   &&  ||  !  \n


%token IF WHILE ELSE NULL PROC MALLOC VAR THEN 


%start prog                   /* the entry point */
%type <AST.> prog  

(* non-terminal declaration *)
%type <bool> boolExp

%type <a'> expr


%type <a'>cmd

%type <a'>varDeclr
%type <a'>procCall
%type <a'>objAlloc
%type <a'>varAssn
%type <a'>fieldAssn
%type <a'>seqCtrl
//%type <a'>parallelism


%% /* rules */

prog :
    c1=cmd EOF {startContructor(c1)} 


expr:
    fld=FLD                             {expnConstructor_fld(fld)}

    |mum=INT            {expnConstructor_ari_int(num)}
    |LPAREN e1=expr MINUS e2=expr RPAREN  {expnConstructor_ari_min(e1 e2)} 

    |NULL                           {expnConstructor_loc_null}
    |VARidt                         {}
    |LPAREN expr DOT expr RPAREN    {} 

    |PROC VARidt COLON cmd          {}



boolExp :
     expr LESSTHAN expr             {}
    | TorF                          {}


cmd:
      varDeclr                      {}
    | procCall                      {}
    | objAlloc                      {}
    | varAssn                       {}
    | fieldAssn                     {}
    | seqCtrl                       {}

varDeclr:
    | VAR VARidt SEMICOLON cmd      {}
procCall:
    | expr LPAREN expr RPAREN       {}
objAlloc:
    | MALLOC LPAREN VARidt RPAREN   {}
varAssn:
    | VARidt EQL expr               {}
fieldAssn:
    | expr DOT expr EQL expr        {}

seqCtrl:
     IF boolExp THEN cmd ELSE cmd           {}
    | WHILE boolExp THEN cmd                {}
    | LBRACKET cmd SEMICOLON cmd RBRACKET   {}



