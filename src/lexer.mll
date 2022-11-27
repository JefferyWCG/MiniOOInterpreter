(* File lexer.mll *)
{
open Parser  (* Type token defined in parser.mli *)
}
rule token = parse
    [' ' '\t' '\n'] { token lexbuf } (* skip blanks and tabs *)
    |"if"            {IF} 
    |"while"         {WHILE} 
    |"else"          {ELSE}
    |"null"          {NULL}
    |"proc"          {PROC}
    |"malloc"        {MALLOC}
    |"var"           {VAR}
    |"then"          {THEN}
    |"printf"        {PRINT}
    |"<"             {LESSTHAN}
    |"=="            {EQLEQL}
    |"="             {EQL}
    |"+"             {PLUS}
    |"*"             {TIMES}
    |"-"             {MINUS}
    |"("             {LPAREN}
    |")"             {RPAREN}
    |";"             {SEMICOLON}
    |":"             {COLON}
    |"."             {DOT}
    |eof             {EOF} (*28*)
    |("true"|"false") as tf {TorF (bool_of_string tf)}
    |"{"             {LBRACKET}
    |"}"            {RBRACKET}
    | "|||"          {PARA}
    |"atmo"          {ATOM}
    |"skip"          {SKIP}

    |['0'-'9']+ as num   { INT (int_of_string num) }
    |(['A'-'Z'])(['a'-'z'] | ['A'-'Z'] | ['0'-'9'])* as idt  { FLD idt }
    |(['a'-'z'])(['a'-'z'] | ['A'-'Z'] | ['0'-'9'])* as idt  { VARidt idt }

