/* File parser.mly */

%{ (* TBD *)

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
%type <unit> prog  

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
    cmd EOF { print_int $1 ; print_newline(); flush stdout; () } //hack


expr:
    FLD

    |INT 
    |LPAREN expr MINUS expr RPAREN  {} 

    |NULL                           {}
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



