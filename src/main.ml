(* File main.ml *)
open Parsing
open AST

let str ="
var x; 
  {x=5-2; 
    if 5<2 then x=2 else y=1
  };

"
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
| [] -> print_string "scope error"; true
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
  )
|{raw=Expn expn; scope=_} ->
  (match expn with
    |Fieldn _ -> setScopeChecker node false
    |AriExpn arin -> (
      match arin with
        |Int num -> setScopeChecker node false
        |MinExpn (n1,n2) -> setSymtables [n1;n2] (getSymtable node);
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
  )
| {raw=Start subn; scope=_} -> setSymtables [node;subn] []; setScopeChecker node (implementScope subn)


let rec printNode node = 
  print_string "\n";
  match node with
  | {raw=CmdN cmdn; scope=_} -> 
    print_string "cmd with "; 
    (match cmdn with 
    |VarDeclrn (varName,subn) -> print_string "variable declaration statement, varName: "; print_string varName; printNode subn
    |ObjAllocn subn ->  print_string "object allocation statement "
    |VarAssnn  subn ->  print_string "variable assignment statement "       
    |FieldAssnn subn -> print_string "field assignment statement "                    
    |SeqCtrln subn ->  print_string "sequential control statement "
    |Parallelism (Para (n1,n2))-> print_string "parallelism control statement"; printNode n1; printNode n2
    |_ -> print_string "cmd match failure"
    )
  | {raw=Start subnode; scope=_} -> print_string "start\n"; printNode subnode
  |_-> print_string "error"

  let i= implementScope startNode


