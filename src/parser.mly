/* File parser.mly */

%{ (* header *)
  
%} /* declarations */
%token <string >VARidt  /* variable with an identifier (string)*/
%token <string >FIELDidt  /* field with an identifier (string) HACK HACK HACK*/ 

(*key words and symbol tokens*)

%token <int> INT
%token <bool> TorF  //    true/false 
%token EQLEQL  GRATER  LESSTHAN  GOE  LOE  NEQL
//       ==       >       <      >=    <=   <>

%token EQL PLUS MINUS TIMES DIV LPAREN RPAREN SEMICOLON COLON DOT AND  OR NOT
//      =   +     -     *    /    (      )        ;       :    .   &&  ||  !


%token IF WHILE ELSE NULL PROC MALLOC VAR


%start prog                   /* the entry point */
%type <CalculatorDeclarations.typeProg> prog  

(* non-terminal declaration *)
%type <bool> boolExp

%type <a'> expr
%type <a'> ariExpr
%type <a'> locExpr
%type <a'> procExpr
%type <a'> fieldExpr (* ? difference from  locExp ?? HACK HACK HACK *)
%type cmd
%type varDeclr
%type procCall
%type objAlloc
%type varAssn
%type fieldAss
%type seqCtrl
%type parallelism


%left PLUS MINUS          /* lowest precedence  */
%left TIMES DIV           /* medium precedence  */
%nonassoc UMINUS          /* highest precedence */

%% /* rules */

prog :
    cmds EOL  { print_int $1 ; print_newline(); flush stdout; () }
	
expr:
    fieldExpr
    | ariExpr
    | locExpr
    | procExpr

fieldExpr://hack hack hack ??? need specification

ariExpr :
    e1 = expr PLUS  e2 = expr     { e1 + e2 }
    | e1 = expr MINUS e2 = expr     { e1 - e2 }
    | e1 = expr TIMES e2 = expr     { e1 * e2 }
    | e1 = expr DIV   e2 = expr     { e1 / e2 }
    | MINUS e = expr %prec UMINUS   { - e }
    | LPAREN e = expr RPAREN        { e }
    | v = INT                       { v }
  
locExpr :
    e = VARidt                    {e}
    | NULL
    | e1=expr DOT e2=expr

procExpr :
    PROC VARidt COLON cmd//hack hack hack -> what if the procedure takes multiple parameters?


boolExp :
    boolExp OR boolExp
    | boolExp AND boolExp
    | NOT boolExp    
    | LPAREN e = boolExp RPAREN  

    | ariExpr EQLEQL ariExpr
    | ariExpr GRATER ariExpr
    | ariExpr GOE ariExpr
    | ariExpr LESSTHAN ariExpr
    | ariExpr LOE ariExpr
    | ariExpr NEQL ariExpr

    | TorF


cmd:
    varDeclr
    | procCall
    | objAlloc
    | varAssn
    | fieldAss
    | seqCtrl
    | parallelism

varDeclr:
    | VAR VARidt //hack hack hack -> see paper
procCall:
    | expr LPAREN expr RPAREN 
objAlloc
    | MALLOC expr LPAREN VARidt RPAREN 
varAssn
    | VARidt EQL expr
fieldAss
    | expr DOT expr EQL expr    
//seqCtrl
//parallelism hack hack hack


%% (* trailer *)
