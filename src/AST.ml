

type ariExpn = Int of int | MinExpn of  (expn*expn) (* e-e *)
and locExpn = NULLn | VarIdtn of string| FldExpn of (expn*expn) (*e.e*)
and procDcln = (string*cmdn)
and expn = Fieldn of string
          |AriExpn of ariExpn
          |LocExpn of locExpn 
          |ProcDcln of procDcln
and boolexpn = |TorF of bool|LessThann of (expn*expn) (*e<e*)

and seqCtrln = IfStm of (bool*cmdn*cmdn)| WhileStm of (bool*cmdn) | TwoCmds of (cmdn*cmdn)
and cmdn = VarDeclrn of (string*cmdn) (* var str; cmd*)                
          |ProcCalln of (expn*expn)  (* e(e) *)      
          |ObjAllocn of string       (* malloc()*)          
          |VarAssnn of (string*expn)   (* x=1 *)              
          |FieldAssnn of (expn*expn*expn)                    
          |SeqCtrln of seqCtrln                      

type undecNode = Expn of expn| BoolExpN of boolexpn|CmdN of cmdn|Start of cmdn

type numOrFld = Int of int | FLD of string | NULL
type symbTable =(string * numOrFld) list ;;
type scopeAtrb ={ v:symbTable; e:bool } 

type node = {raw:undecNode; mutable scope:scopeAtrb}


(*------------------------------------------------------------*)
let startContructor cmd = match cmd with 
  |CmdN cmdn -> Start cmdn
  |_ -> failwith"fail to match startContructor"
let expnConstructor_fld fld = Expn (Fieldn fld)
let expnConstructor_ari_int num = Expn(AriExpn(Int num))
let expnConstructor_ari_min exp1 exp2= Expn(AriExpn(MinExpn (exp1,exp2) ))
let expnConstructor_loc_null = Expn(LocExpn(NULLn))






