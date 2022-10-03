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
    |"=="            {ELQELQ}
    |">="            {GOE}   
    |"<="            {LOE}
    |"<>"            {NEQL}
    |'>'             {GRATER}
    |'<'             {LESSTHAN}
    |"&&"            {AND}
    |"||"            {OR}
    |'='             {EQL}
    |'+'             {PLUS}
    |'-'             {MINUS}
    |'*'             {TIMES}
    |'/'             {DIV}
    |'('             {LPAREN}
    |')'             {RPAREN}
    |';'             {SEMICOLON}
    |':'             {COLON}
    |'.'             {DOT}
    |'!'             {NOT}
    |'\n'            {EOL}
    |eof             {EOF} (*28*)
    |("true"|"false"){TorF}

    |['0'-'9']+ as num   { INT (int_of_string num) }
    |(['a'-'z'] | ['A'-'Z'])(['a'-'z'] | ['A'-'Z'] | ['0'-'9'])* as idt  { VARidt idt }

