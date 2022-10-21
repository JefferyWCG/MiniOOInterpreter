/* File parser.mly */

%{

open AST

%} /* declarations */
%token <string >VARidt  FLD/* variable with an identifier (string)*/

(*key words and symbol tokens*)

%token <int> INT 
%token <bool> TorF  //    true/false 
%token  LESSTHAN 
%token EQL MINUS LPAREN RPAREN SEMICOLON COLON DOT  EOF  LBRACKET RBRACKET PARA ATOM SKIP
%token IF WHILE ELSE NULL PROC MALLOC VAR THEN 

%start prog                   /* the entry point */
%type <AST.node>prog  

(* non-terminal declaration *)
%type <bool> boolExp
%type <a'> expr
%type <a'>cmd

%% /* rules */

prog :
    c1=cmd EOF {startContructor(c1)} 

expr:
    fld=FLD                                     {expnConstructor_fld(fld)}
    |mum=INT                                    {expnConstructor_ari_int num }
    |LPAREN n1=expr MINUS n2=expr RPAREN        {expnConstructor_ari_min [n1,n2] } 
    |NULL                                       {expnConstructor_loc_null}
    |str=VARidt                                 {expnConstructor_loc_var str}
    |LPAREN n1=expr DOT n2=expr RPAREN          {expnConstructor_fldexp [n1,n2]} 
    |PROC str=VARidt COLON n1=cmd               {expnConstructor_procDecl[str,n1]}

boolExp :
     n1=expr LESSTHAN n2=expr                   {boolExpnConstructor_lessThan [n1,n2]}
    | tf=TorF                                  {boolExpnConstructor_TorF tf}

cmd:
    | VAR str=VARidt SEMICOLON n1=cmd           {boolExpnConstructor_lessThan [str,n1]}  // variable declaration
    | n1=expr LPAREN n2=expr RPAREN             {cmdExpnConstructor_funcCall[n1,n2]}  // function call
    | MALLOC LPAREN str=VARidt RPAREN           {cmdExpnConstructor_malloc str}  // malloc
    | str=VARidt EQL n1=expr                    {cmdExpnConstructor_varAssn [str,n1]}  // variable assignment
    | n1=expr DOT n2=expr EQL n3=expr           {cmdExpnConstructor_fldAssn [n1,n2,n3]}  // field assignment
    | IF b=boolExp THEN n1=cmd ELSE n2=cmd      {cmdExpnConstructor_if [b,n1,n2]}  // if
    | WHILE b=boolExp THEN n1=cmd               {cmdExpnConstructor_while [b,n1]}  // while
    | LBRACKET n1=cmd SEMICOLON n2=cmd RBRACKET {cmdExpnConstructor_2cmd [n1,n2]}  // two commands
    | SKIP                                      {cmdExpnConstructor_skip}  // skip
    | LBRACKET n1=cmd PARA n2=cmd RBRACKET      {cmdExpnConstructor_para [n1,n2]}  // parallelism
    | ATOM LPAREN n1=cmd RPAREN                 {cmdExpnConstructor_atom n1}  // atomic
