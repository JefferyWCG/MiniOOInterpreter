(* File Docoration.ml *)
open Parsing
open AST
exception Excpetion of string

let str1 ="
var x; 
  {x=5-2; 
  {var y;y=x-1; x=100}
  };
"
let str2 = "
var x; 
  var y;
    {var z; 
      malloc(x);
      x=1};
"

let str3 = "
  var x;
    var y;
    {malloc(x); {x.Foo = Bar;{malloc (y);y.(x.Foo)=Quiz}}};"

let str = "
  var x;
  var y;{
    malloc(y);
    {x = proc a:y.Foo=a;
    x(100)}};"
let lexbuf = Lexing.from_string str 
let startNode = Parser.prog Lexer.token lexbuf

let setSymtable node symtab = node.scope<-Done {v=symtab; e=true}
let rec setSymtables nodes symtab = match nodes with
|[] -> ()
|h::t -> setSymtable h symtab; setSymtables t symtab

let setScopeChecker node boolean = match node with
|{raw=_; scope=Done record} ->
  record.e <- boolean;boolean
|_-> print_string "error in assign scope checker ()\n"; boolean

let getSymtable node = match node with
|{raw=_; scope=Done {e= _; v}} -> v
|_->print_string "error in assign getting Symtable\n"; []

let rec checkScope varName symtab = match symtab with
| [] -> print_string ("scope error "^varName); true
| h::t -> if h = varName then false else checkScope varName t 

let checkScope varName node = checkScope varName (getSymtable node)

let rec implementScope node =  match node with
|{raw=CmdN cmdn; scope=_} ->
  (match cmdn with 
    |VarDeclrn (varName,subn) ->  
      setSymtable subn (varName::getSymtable node); 
      setScopeChecker node (implementScope subn)
    |ProcCalln (n1,n2) ->
      setSymtables [n1;n2] (getSymtable node);
      setScopeChecker node (implementScope n1||implementScope n2)
    |ObjAllocn varName -> setScopeChecker node (checkScope varName node)
    |VarAssnn  (varn,n) ->  
      setSymtable n (getSymtable node);
      setScopeChecker node ((implementScope n)||checkScope varn node)
    |FieldAssnn (e1,e2,e3) -> 
      setSymtables [e1;e2;e3] (getSymtable node);
      setScopeChecker node (implementScope e1||implementScope e2||implementScope e3) 
    |SeqCtrln seqn -> (
      match seqn with
        |IfStm (b,n1,n2)->
          setSymtables [b;n1;n2] (getSymtable node);
          setScopeChecker node (implementScope b||implementScope n1||implementScope n2)
        |WhileStm (b,n) ->       
        setSymtables [b;n] (getSymtable node);
        setScopeChecker node (implementScope b||implementScope n)
        |TwoCmds (n1,n2) ->
          setSymtables [n1;n2] (getSymtable node);
          setScopeChecker node (implementScope n1||implementScope n2)
        |SKIP -> setScopeChecker node false
        );
    |Parallelism subn ->(
      match subn with
        |Para (n1,n2) ->
          setSymtables [n1;n2] (getSymtable node);
          setScopeChecker node (implementScope n1||implementScope n2)
        |Atom n -> setSymtable n []; setScopeChecker node (implementScope n)
      )
      |Print n -> setSymtable n []; setScopeChecker node (implementScope n)
    |_-> raise (Excpetion "scope error 138")
  )
|{raw=Expn expn; scope=_} ->
  (match expn with
    |Fieldn _ -> setScopeChecker node false
    |AriExpn arin -> (
      match arin with
        |Int num -> setScopeChecker node false
        |MinExpn (n1,n2) -> setSymtables [n1;n2] (getSymtable node);
        setScopeChecker node (implementScope n1||implementScope n2)
        |PlusExpn (n1,n2) -> setSymtables [n1;n2] (getSymtable node);
        setScopeChecker node (implementScope n1||implementScope n2)
        |TimesExpn (n1,n2) -> setSymtables [n1;n2] (getSymtable node);
        setScopeChecker node (implementScope n1||implementScope n2)
      )
    |LocExpn locn ->(
      match locn with
        |NULLn -> setScopeChecker node false
        |VarIdtn varn -> setScopeChecker node (checkScope varn node)
        |FldExpn (n1,n2) -> 
          setSymtables [n1;n2] (getSymtable node);
          setScopeChecker node (implementScope n1||implementScope n2)
     )
    |ProcDcln (varn,n) ->
      setSymtable n (getSymtable node);
      setScopeChecker node ((implementScope n)||checkScope varn node)
  )
| {raw=BoolExpN subn; scope=_} -> 
  (match subn with
    |TorF _ -> setScopeChecker node false;
    |LessThann (n1,n2) ->
      setSymtables [n1;n2] (getSymtable node);
      setScopeChecker node (implementScope n1||implementScope n2)
    |Eql (n1,n2) ->
      setSymtables [n1;n2] (getSymtable node);
      setScopeChecker node (implementScope n1||implementScope n2)
  )
| {raw=Start subn; scope=_} -> setSymtables [node;subn] []; setScopeChecker node (implementScope subn)


let rec setScopeChecker node boolean = match node with
|{raw=_; scope=Done record} ->
  record.e <- boolean;boolean
|_-> print_string "error in assign scope checker ()\n"; boolean

let getSymtable node = match node with
|{raw=_; scope=Done {e= _; v}} -> v
|_->print_string "error in assign getting Symtable\n"; []

let rec checkScope varName symtab = match symtab with
| [] -> print_string "scope error"; true
| h::t -> if h = varName then false else checkScope varName t 

let checkScope varName node = checkScope varName (getSymtable node)

let rec printNode node =  match node with
|{raw=CmdN cmdn; scope=_} ->
  (match cmdn with 
    |VarDeclrn (varName,subn) -> "variable Declaration of "^varName
    |ProcCalln (n1,n2) -> "Procedure call"
    |ObjAllocn varName -> "malloc of: "^varName
    |VarAssnn  (varn,n) ->  "variable assignment of variable: "^varn^""
    |FieldAssnn (e1,e2,e3) -> "filed assignment"
    |SeqCtrln seqn -> (
      match seqn with
        |IfStm (b,n1,n2)-> "if statement"
        |WhileStm (b,n) -> "while statement"
        |TwoCmds (n1,n2) ->"two commands"
        |SKIP -> "skip"
        );
    |Parallelism subn ->(
      match subn with
        |Para (n1,n2) ->"parallelism"
        |Atom n -> "atmoic"
      )
    |Block subn-> "Block"
    |Print subn->"print"
  )
|{raw=Expn expn; scope=_} ->
  (match expn with
    |Fieldn fld -> "field: "^fld 
    |AriExpn arin -> (
      match arin with
        |Int num -> string_of_int num
        |MinExpn (n1,n2) -> "minus expression"
        |PlusExpn (n1,n2) -> "plus expression"
        |TimesExpn (n1,n2) -> "times expression"
      )
    |LocExpn locn ->(
      match locn with
        |NULLn -> "null"
        |VarIdtn varn -> varn
        |FldExpn (n1,n2) -> "field expression"
     )
    |ProcDcln (varn,n) -> "procedure with parameter: "^varn
  )
| {raw=BoolExpN subn; scope=_} -> 
  (match subn with
    |TorF tf -> string_of_bool tf
    |LessThann (n1,n2) -> "less than"
    |Eql (n1,n2) -> "=="
  )
| {raw=Start subn; scope=_} -> "start"
let printNodeWithSymtab node = match node with
|{raw=_; scope=  Done { v=symbTable; e=_ }} -> printNode node ^ ".    SymtableTable:"^ (List.fold_left (fun acc cur->acc^cur^"; ") "[" symbTable) ^"]"
|_ -> "error in print symtable"
let rec getSubNode node = match node with
|{raw=CmdN cmdn; scope=_} ->
  (match cmdn with 
    |VarDeclrn (varName,subn) -> [subn]
    |ProcCalln (n1,n2) -> [n1;n2]
    |ObjAllocn varName -> []
    |VarAssnn  (varn,n) ->  [n]
    |FieldAssnn (e1,e2,e3) -> [e1;e2;e3]
    |SeqCtrln seqn -> (
      match seqn with
        |IfStm (b,n1,n2)-> [b;n1;n2]
        |WhileStm (b,n) -> [b;n]
        |TwoCmds (n1,n2) ->[n1;n2]
        |SKIP -> []
        );
    |Parallelism subn ->(
      match subn with
        |Para (n1,n2) ->[n1;n2]
        |Atom n -> [n]
      )
    |Print expn -> [expn]
    |Block cmdn-> [cmdn]
  )
|{raw=Expn expn; scope=_} ->
  (match expn with
    |Fieldn fld -> []
    |AriExpn arin -> (
      match arin with
        |Int num -> []
        |MinExpn (n1,n2) -> [n1;n2]
        |PlusExpn (n1,n2) -> [n1;n2]
        |TimesExpn (n1,n2) -> [n1;n2]
      )
    |LocExpn locn ->(
      match locn with
        |NULLn -> []
        |VarIdtn varn -> []
        |FldExpn (n1,n2) -> [n1;n2]
     )
    |ProcDcln (varn,n) -> [n]
  )
| {raw=BoolExpN subn; scope=_} -> 
  (match subn with
    |TorF tf -> []
    |LessThann (n1,n2) -> [n1;n2]
    |Eql (n1,n2) -> [n1;n2]
  )
| {raw=Start subn; scope=_} -> [subn]


  let i= implementScope startNode


(*
   Created by Martin Jambon and placed in the Public Domain on June 1, 2019.
   Print a tree or a DAG as tree, similarly to the 'tree' command.
  refernce  https://gist.github.com/mjambon/75f54d3c9f1a352b38a8eab81880a735
*)
open Printf
let rec iter f = function
  | [] -> ()
  | [x] ->
      f true x
  | x :: tl ->
      f false x;
      iter f tl

let to_buffer ?(line_prefix = "") ~get_name ~get_children buf x =
  let rec print_root indent x =
    bprintf buf "%s\n" (get_name x);
    let children = get_children x in
    iter (print_child indent) children
  and print_child indent is_last x =
    let line =
      if is_last then
        "└── "
      else
        "├── "
    in
    bprintf buf "%s%s" indent line;
    let extra_indent =
      if is_last then
        "    "
      else
        "│   "
    in
    print_root (indent ^ extra_indent) x
  in
  Buffer.add_string buf line_prefix;
  print_root line_prefix x

let to_string ?line_prefix ~get_name ~get_children x =
  let buf = Buffer.create 1000 in
  to_buffer ?line_prefix ~get_name ~get_children buf x;
  Buffer.contents buf


let testPrint inputNode =
  let tree =inputNode
  in
  let get_name = printNode
  in
  let get_children = getSubNode
  in
  let result = to_string ~line_prefix:"* " ~get_name ~get_children tree in
  print_string result 
;;
testPrint startNode

