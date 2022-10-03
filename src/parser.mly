/* File parser.mly */

%{ (* TBD *)

%} /* declarations */
%token <string >VARidt  /* variable with an identifier (string)*/

(*key words and symbol tokens*)

%token <int> INT 
%token <bool> TorF  //    true/false 
%token EQLEQL  GRATER  LESSTHAN  GOE  LOE  NEQL  
//       ==       >       <      >=    <=   <>

%token EQL PLUS MINUS TIMES DIV LPAREN RPAREN SEMICOLON COLON DOT AND  OR NOT EOL EOF  
//      =   +     -     *    /    (      )        ;       :    .   &&  ||  !  \n


%token IF WHILE ELSE NULL PROC MALLOC VAR THEN 


%start prog                   /* the entry point */
%type <CalculatorDeclarations.typeProg> prog  

(* non-terminal declaration *)
%type <bool> boolExp

%type <a'> expr
%type <a'> ariExpr
%type <a'> locExpr
%type <a'> procExpr
%type <a'> fieldExpr (* ? difference from  locExp ?? HACK HACK HACK *)

%type <a'>cmd
%type <a'>cmds

%type <a'>varDeclr
%type <a'>procCall
%type <a'>objAlloc
%type <a'>varAssn
%type <a'>fieldAssn
%type <a'>seqCtrl
%type <a'>parallelism


%left PLUS MINUS          /* lowest precedence  */
%left TIMES DIV           /* medium precedence  */
%nonassoc UMINUS          /* highest precedence */

%% /* rules */

prog :
    cmds EOF { print_int $1 ; print_newline(); flush stdout; () } //hack

cmds :
    cmd SEMICOLON
    | cmd SEMICOLON cmds {}
    | cmd SEMICOLON EOL cmds {}


expr:
      fieldExpr {}
    | ariExpr   {}
    | locExpr   {}
    | procExpr  {}

fieldExpr:
     VARidt DOT VARidt{}
//fieldExpr://hack hack hack ??? need specification

ariExpr:
      e1 = expr PLUS  e2 = expr     { e1 + e2 }
    | e1 = expr MINUS e2 = expr     { e1 - e2 }
    | e1 = expr TIMES e2 = expr     { e1 * e2 }
    | e1 = expr DIV   e2 = expr     { e1 / e2 }
    | MINUS e = expr %prec UMINUS   { - e }
    | LPAREN e = expr RPAREN        { e }
    | v = INT                       { v }
  
locExpr :
      e = VARidt                    {e}
    | NULL                          {}
    | e1=expr DOT e2=expr           {}

procExpr :
    PROC VARidt COLON cmds           {}//hack hack hack -> what if the procedure takes multiple parameters? P{}
    | PROC fieldExpr COLON cmds       {}

boolExp :
      boolExp OR boolExp            {}
    | boolExp AND boolExp           {}
    | NOT boolExp                   {}
    | LPAREN e = boolExp RPAREN     {}

    | ariExpr EQLEQL ariExpr        {}
    | ariExpr GRATER ariExpr        {}
    | ariExpr GOE ariExpr           {}
    | ariExpr LESSTHAN ariExpr      {}
    | ariExpr LOE ariExpr           {}
    | ariExpr NEQL ariExpr          {}

    | TorF                          {}


cmd:
      varDeclr                      {}
    | procCall                      {}
    | objAlloc                      {}
    | varAssn                       {}
    | fieldAssn                     {}
    | seqCtrl                       {}
    | parallelism                   {}

varDeclr:
    | VAR VARidt                        {}//hack hack hack -> see paper
procCall:
    | expr LPAREN expr RPAREN           {}
objAlloc:
    | MALLOC expr LPAREN VARidt RPAREN  {}
varAssn:
    | VARidt EQL expr                   {}
fieldAssn:
    | fieldExpr EQL expr            {}


// hack should we support multiple commands
seqCtrl:
    WHILE boolExp THEN cmd ELSE cmd     {}
    | IF boolExp THEN cmd ELSE cmd      {}
    | WHILE boolExp THEN cmd            {}
    | IF boolExp THEN cmd               {}


parallelism :{}

//hack hack hack


%% (* trailer *)
