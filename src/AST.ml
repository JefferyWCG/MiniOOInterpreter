type ariExpn = Int of int | MinExpn of  (node*node) (* e-e *)
and locExpn = NULLn | VarIdtn of string| FldExpn of (node*node) (*e.e*)
and expn = Fieldn of string
  |AriExpn of ariExpn
  |LocExpn of locExpn 
  |ProcDcln of (string*node)
and boolexpn = |TorF of bool|LessThann of (node*node) (*e<e*)

and seqCtrln = IfStm of (node*node*node)| WhileStm of (node*node) | TwoCmds of (node*node) | SKIP
and parallelism = Para of (node*node) | Atom of node
and cmdn = VarDeclrn of (string*node) (* var str; cmd*)                
  |ProcCalln of (node*node)  (* e(e) *)      
  |ObjAllocn of string       (* malloc()*)          
  |VarAssnn of (string*node)   (* x=1 *)              
  |FieldAssnn of (node*node*node)                    
  |SeqCtrln of seqCtrln    
  |Parallelism of parallelism       
  |Block of node      

and undecNode = Expn of expn| BoolExpN of boolexpn|CmdN of cmdn|Start of node

and symbTable =(string) list (* record all variable name*)
and scopeAtrb = Done of { v:symbTable; mutable e:bool }| TBDscope

and node = {raw:undecNode; mutable scope:scopeAtrb}


(*------------------------------------------------------------*)
let startContructor node = {scope=TBDscope;raw=Start node }

let expnConstructor_fld fld = {scope=TBDscope;raw=Expn (Fieldn fld)} 

let expnConstructor_ari_int num = {scope=TBDscope;raw=Expn (AriExpn (Int num))} 

let expnConstructor_ari_min tup =  {scope=TBDscope;raw=Expn (AriExpn (MinExpn tup))}

let expnConstructor_loc_null = {raw=Expn(LocExpn(NULLn)); scope=TBDscope}

let expnConstructor_loc_var str = {scope=TBDscope;raw=Expn (LocExpn (VarIdtn str))} 

let expnConstructor_fldexp tup = {scope=TBDscope; raw =Expn(LocExpn(FldExpn tup))}

let expnConstructor_procDecl tup = {scope=TBDscope; raw=Expn(ProcDcln tup)}


  (*--- boolean expression ---*)
let boolExpnConstructor_lessThan tup = {scope=TBDscope; raw=BoolExpN(LessThann tup)}
let boolExpnConstructor_TorF tf = {scope=TBDscope; raw=BoolExpN(TorF tf)}


  (*--- commands constructor  ---*)
let cmdExpnConstructor_varDecl tup = {scope=TBDscope; raw = CmdN (VarDeclrn tup)}
let cmdExpnConstructor_funcCall tup = {scope=TBDscope; raw = CmdN (ProcCalln tup)}
let cmdExpnConstructor_malloc str = {scope=TBDscope; raw = CmdN (ObjAllocn str)}
let cmdExpnConstructor_varAssn tup = {scope=TBDscope; raw = CmdN (VarAssnn tup)}
let cmdExpnConstructor_fldAssn tup = {scope=TBDscope; raw = CmdN (FieldAssnn tup)}
let cmdExpnConstructor_if tup= {scope=TBDscope; raw = CmdN (SeqCtrln (IfStm tup))}
let cmdExpnConstructor_while tup = {scope=TBDscope; raw = CmdN (SeqCtrln (WhileStm tup))}
let cmdExpnConstructor_2cmd tup = {scope=TBDscope; raw = CmdN (SeqCtrln (TwoCmds tup))}
let cmdExpnConstructor_skip = {scope=TBDscope; raw = CmdN (SeqCtrln SKIP)}
let cmdExpnConstructor_para tup = {scope=TBDscope; raw = CmdN (Parallelism (Para tup))}
let cmdExpnConstructor_atom n1 = {scope=TBDscope; raw = CmdN (Parallelism (Atom n1))}
