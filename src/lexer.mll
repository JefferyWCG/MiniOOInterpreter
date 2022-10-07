(* File lexer.mll *)
{
open parser  (* Type token defined in parser.mli *)
}
rule token = parse
    "if"            {IF} 
    |"while"         {WHILE} 
    |"else"          {ELSE}
    |"null"          {NULL}
    |"proc"          {PROC}
    |"malloc"        {MALLOC}
    |"var"           {VAR}
    |"then"          {THEN}
    |'<'             {LESSTHAN}
    |'='             {EQL}
    |'+'             {PLUS}
    |'-'             {MINUS}
    |'('             {LPAREN}
    |')'             {RPAREN}
    |';'             {SEMICOLON}
    |':'             {COLON}
    |'.'             {DOT}
    |'!'             {NOT}
    |'\n'            {EOL}
    |eof             {EOF} (*28*)
    |("true"|"false"){TorF}
    |'{'             {LBRACKET}
    |'}'             {RBRACKET}

    |['0'-'9']+ as num   { INT (int_of_string num) }
    |(['A'-'Z'])(['a'-'z'] | ['A'-'Z'] | ['0'-'9'])* as idt  { FLD idt }
    |(['a'-'z'])(['a'-'z'] | ['A'-'Z'] | ['0'-'9'])* as idt  { VARidt idt }

