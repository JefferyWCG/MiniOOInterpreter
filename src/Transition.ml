(* Semantic transition *)
open AST 
open Domain


let rec eval exp st hp= match exp with
|Fieldn fieldStr -> Value (FldVal (Fld fieldStr))
|AriExpn ariExpn -> (match ariExpn with
  |Int num -> Value (IntVal (Num num))
  |MinExpn ({raw=Expn exp1;  scope=_},{raw=Expn exp2;  scope=_}) -> 
    let v1 = eval exp1 st hp and v2 = eval exp2 st hp in 
      (match (v1,v2) with 
      | (Value (IntVal Num num1), Value (IntVal Num num2)) -> Value (IntVal( Num (num1-num2)))
      |_ -> print_string "evaluation error in minus expression"; Error
      )
  |_-> raise (Excpetion "evaluation error in arithmatic expression")
  )
|LocExpn locExpn -> (match locExpn with
  |NULLn -> Value (LocVal NULL)
  |VarIdtn varName -> getVar varName st hp
  |FldExpn ({raw=Expn exp1;  scope=_},{raw=Expn exp2;  scope=_}) -> 
    let l = eval exp1 st hp and f = eval exp2 st hp in
      let (field,isField )= match f with |Value ( FldVal Fld fld)->(Fld fld,true) |_-> (Fld "errorOccur !!!!",false) 
      and (obj,isObject) = match l with |Value (LocVal (ObjLoc(Obj obj)))-> (Obj obj,true) |_->(Obj 9999999999,false) in
      if(isField && isObject && isInHeapDomain obj field hp) 
        then getfromHeap obj field hp 
        else Error
  |_-> raise (Excpetion "evaluation error in location expression")
)
|ProcDcln (varName, {raw=CmdN cmdn;  scope=_}) -> Value (CloVal (Clo (varName,(Cmd cmdn), st)))
|_-> raise (Excpetion "evaluation error")

  (*
let rec transition config = match config with 
| ControlStateConfig 
  (Cmd (VarDeclrn (varName,{scope=_; raw = CmdN cmdn})),
  (st,hp)) ->  let l = getNewObj () in
      let st1 = Decl [(varName,l)] :: st  
      and hp1 = ((l,Fld "val"),Value (LocVal NULL)) :: hp in
      ControlStateConfig (Block (Cmd cmdn), (st1,hp1))

| ControlStateConfig
  ((Block control),
  (st,hp))-> (match transition (ControlStateConfig (control,(st,hp))) with 
    |StateConfig ((Decl _:: st1),hp1) -> StateConfig (st1,hp1)
    |ControlStateConfig (control1,state1) -> ControlStateConfig ((Block control1),state1)
    |_-> raise (Excpetion "transition block statement error"))
|_->  raise (Excpetion "transition error");;

*)


(*
let initConfig = ControlStateConfig (Cmd (match startNode.raw with 
  (Cmdn cmdn)
) )*
*)
(* get a unique new space in heap -> return that location*)





let rec transition control st hp  =  match control with
|Cmd command->
  (match command with 
    |VarDeclrn (varName,subcmd) ->  
      let l=getNewObj() in
        let st1 =  (Decl [varName,l]) ::st
        and hp1 = ((l,(Fld "val")),(Value (LocVal NULL)))::hp 
        and blockControl = Block subcmd in
        ControlStateConfig ( (Cmd blockControl),(st1,hp1))
    |ProcCalln (n1,n2) ->
      raise (Excpetion "TBD")

    |ObjAllocn varName ->  raise (Excpetion "TBD")
    |VarAssnn  (varn,{raw=Expn exp;  scope=keepScope1}) ->  
      (match (eval exp st hp) with
        |Error->ERROR
        |v->StateConfig(st,setHeap (getFromStack varn st) (Fld "val") v hp))

    |FieldAssnn (e1,e2,e3) -> 
      raise (Excpetion "TBD")

    |SeqCtrln seqn -> (
      match seqn with
        |IfStm (b,n1,n2)->
           raise (Excpetion "TBD")
        |WhileStm (b,n) ->       
          raise (Excpetion "TBD")

        |TwoCmds ({raw=CmdN subcmd1;  scope=keepScope1},{raw=CmdN subcmd2;  scope=keepScope2}) ->
          (match transition (Cmd subcmd1) st hp with
          |ControlStateConfig (Cmd cmdn,(st1,hp1))-> ControlStateConfig (Cmd (SeqCtrln (TwoCmds ({raw=CmdN cmdn;  scope=keepScope1},{raw=CmdN subcmd2;  scope=keepScope2}))),(st1,hp1))
          |StateConfig (st1,hp1)-> ControlStateConfig (Cmd subcmd2,(st1,hp1))
          |_->raise (Excpetion "transition error in two command "))

        |SKIP ->  raise (Excpetion "TBD")
        |_-> raise (Excpetion "transition error in squential control")
    );
    |Parallelism subn ->(
      match subn with
        |Para (n1,n2) ->
          raise (Excpetion "TBD")
        |Atom n ->  raise (Excpetion "TBD")
      )
    |Block {raw=CmdN subcmd;  scope=keepScope} -> 
      (match transition (Cmd subcmd) st hp with
      |ControlStateConfig (Cmd newCmdn,(st1,hp1))-> ControlStateConfig (Cmd (Block ({raw=CmdN newCmdn;  scope=keepScope})),(st1,hp1))
      |StateConfig (Decl env::st1,hp1)-> StateConfig ((st1,hp1))
      |StateConfig (Call (env,st2)::st1,hp1)-> StateConfig ((st2,hp1))
      |_->raise (Excpetion "transition error in block "))
    |_->raise (Excpetion "cmd109")
  )

(*
  (match expn with
    |Fieldn _ ->  raise (Excpetion "TBD")
    |AriExpn arin -> (
      match arin with
        |Int num ->  raise (Excpetion "TBD")
        |MinExpn (n1,n2) -> raise (Excpetion "TBD")
      )
    |LocExpn locn ->(
      match locn with
        |NULLn -> raise (Excpetion "TBD")
        |VarIdtn varn -> raise (Excpetion "TBD")
        |FldExpn (n1,n2) -> 
          raise (Excpetion "TBD")
     )
    |ProcDcln (varn,n) ->
      raise (Excpetion "TBD")
  )
| {raw=BoolExpN subn; scope=_} -> 
  (match subn with
    |TorF _ -> raise (Excpetion "TBD")
    |LessThann (n1,n2) ->
      raise (Excpetion "TBD")
  )*)
| _ -> raise (Excpetion "TBD")



