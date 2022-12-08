(* Semantic transition *)
open AST
open Domain
open Decoration

let rec eval exp st hp= match exp with
  |Fieldn fieldStr -> Value (FldVal (Fld fieldStr))
  |Parentheses {raw=Expn exp1;  scope=_} -> eval exp1 st hp
  |AriExpn ariExpn -> (match ariExpn with
    |Int num -> Value (IntVal (Num num))
    |MinExpn ({raw=Expn exp1;  scope=_},{raw=Expn exp2;  scope=_}) ->
      let v1 = eval exp1 st hp and v2 = eval exp2 st hp in
        (match (v1,v2) with
        | (Value (IntVal Num num1), Value (IntVal Num num2)) -> Value (IntVal( Num (num1-num2)))
        |_ -> print_string "evaluation error in minus expression, this should never happen!"; Error
        )
    |PlusExpn ({raw=Expn exp1;  scope=_},{raw=Expn exp2;  scope=_}) ->
      let v1 = eval exp1 st hp and v2 = eval exp2 st hp in
        (match (v1,v2) with
        | (Value (IntVal Num num1), Value (IntVal Num num2)) -> Value (IntVal( Num (num1+num2)))
        |_ -> print_string "evaluation error in plus expression, this should never happen!"; Error
        )
    |TimesExpn ({raw=Expn exp1;  scope=_},{raw=Expn exp2;  scope=_}) ->
      let v1 = eval exp1 st hp and v2 = eval exp2 st hp in
        (match (v1,v2) with
        | (Value (IntVal Num num1), Value (IntVal Num num2)) -> Value (IntVal( Num (num1*num2)))
        |_ -> print_string "evaluation error in plus expression, this should never happen!"; Error
        )
    |_-> raise (Excpetion "evaluation error in arithmatic expression, this should never happen!")
    )
  |LocExpn locExpn -> (match locExpn with
    |NULLn -> Value (LocVal NULL)
    |VarIdtn varName -> getVar varName st hp
    |FldExpn ({raw=Expn exp1;  scope=_},{raw=Expn exp2;  scope=_}) ->
      let l = eval exp1 st hp and f = eval exp2 st hp in
        let (field,is_field )= match f with |Value ( FldVal Fld fld)->(Fld fld,true) |_-> (Fld "error occur, this should never happen!",false)
        and (obj,isObject) = match l with |Value (LocVal (ObjLoc(Obj obj)))-> (Obj obj,true) |_->(Obj 0,false) in
        if(isField f hp && (isLocationInHeap l hp) && isInHeapDomain obj field hp)
          then getfromHeap obj field hp
          else Error
    |_-> raise (Excpetion "evaluation error in location expression, this should never happen!")
  )
  |ProcDcln (varName, {raw=CmdN cmdn;  scope=_}) -> Value (CloVal (Clo (varName,(Cmd cmdn), st)))
  |_-> raise (Excpetion "evaluation error, this should never happen")


let rec bool_eval (exp:boolexpn) st hp= match exp with
  |TorF b -> if b then True else False
  |LessThann ({raw=Expn exp1;  scope=_},{raw=Expn exp2;  scope=_}) ->
    let e1 = eval exp1 st hp and e2 = eval exp2 st hp in
      if(isNum e1 hp&& isNum e2 hp) then if (getNumFromTva e1 hp <  getNumFromTva e2 hp) then True else False
      else Error;
  |Eql ({raw=Expn exp1;  scope=_},{raw=Expn exp2;  scope=_})->
    let e1 = eval exp1 st hp and e2 = eval exp2 st hp in
      if((isNum e1 hp&& isNum e2 hp)
        ||(isLocation e1 hp&& isLocation e2 hp
        ||isClosure e1 hp&& isClosure e2 hp)) then if (e1 = e2) then True else False
      else Error;
  |_->raise (Excpetion " boolean evaluation error")






(* the main function for small-step semantics transition *)
let rec transition control st hp  =  match control with
|Cmd command->
  (match command with
    |VarDeclrn (varName,subcmd) ->
      let l = getNewObj() in
        let st1 =  (Decl [varName,l]) ::st
        and hp1 = ((l,(Fld "val")),(Value (LocVal NULL)))::hp
        and blockControl = Block subcmd in
        ControlStateConfig ( (Cmd blockControl),(st1,hp1))

    |ProcCalln ({raw=Expn exp1;  scope=keepScope1},{raw=Expn exp2;  scope=keepScope2}) ->
      let v = eval exp1 st hp in
        (match v with
        |Value (CloVal Clo (x,control,st1)) ->
          let l = getNewObj() in
          let st2 = (Call ([(x,l)],st) ) ::st1
          and hp1 = setHeap l (Fld "val") (eval exp2 st hp) hp
          and blockControl = Block {raw = CmdN (match control with |Cmd subcmdn -> subcmdn); scope=TBDscope} in
          ControlStateConfig (Cmd blockControl, (st2,hp1))
        |_-> ERROR)

    |ObjAllocn varName -> let l = getNewObj() in
        let hp1 = setHeap l (Fld "is_object") Error hp in
          let hp2 = setHeap (getFromStack varName st) (Fld "val") (Value (LocVal (ObjLoc l))) hp1 in
            StateConfig (st,hp2)

    |VarAssnn  (varn,{raw=Expn exp;  scope=keepScope1}) ->
      (match (eval exp st hp) with
        |Error->ERROR
        |v->StateConfig(st,setHeap (getFromStack varn st) (Fld "val") v hp))

    |FieldAssnn ({raw=Expn exp1;  scope=keepScope1},{raw=Expn exp2;  scope=keepScope2},{raw=Expn exp3;  scope=keepScope3}) ->
        let l = eval exp1 st hp and f = eval exp2 st hp in
          if (not (isLocationInHeap l hp)) || (not (isField f hp))
            then ERROR
            else let v1 = eval exp3 st hp in StateConfig (st,setHeap (getObjFromTva l hp) (getFldFromTva f hp) v1 hp)

    |SeqCtrln seqn -> (
      match seqn with
        |IfStm ({raw=BoolExpN b;  scope=keepScope1},{raw=CmdN cmd1;  scope=keepScope2},{raw=CmdN cmd2;  scope=keepScope3})->
          let b1 = bool_eval b st hp in
            (match b1 with
            |True -> ControlStateConfig(Cmd cmd1,(st,hp))
            |False ->ControlStateConfig(Cmd cmd2,(st,hp))
            |Error -> ERROR
            )

        |WhileStm  ({raw=BoolExpN b;  scope=keepScope1},{raw=CmdN cmd1;  scope=keepScope2}) ->
          let b1 = bool_eval b st hp in
          (match b1 with
          |True -> let twoCmd = (SeqCtrln (TwoCmds (
            {raw=CmdN cmd1;  scope=keepScope2},
            {raw=CmdN command;  scope=keepScope2}))) in
              ControlStateConfig(Cmd twoCmd ,(st,hp))
          |False ->StateConfig (st,hp)
          |Error -> ERROR
          )

        |TwoCmds ({raw=CmdN subcmd1;  scope=keepScope1},{raw=CmdN subcmd2;  scope=keepScope2}) ->
          (match transition (Cmd subcmd1) st hp with
          |ControlStateConfig (Cmd cmdn,(st1,hp1))-> ControlStateConfig (Cmd (SeqCtrln (TwoCmds ({raw=CmdN cmdn;  scope=keepScope1},{raw=CmdN subcmd2;  scope=keepScope2}))),(st1,hp1))
          |StateConfig (st1,hp1)-> ControlStateConfig (Cmd subcmd2,(st1,hp1))
          |ERROR->ERROR)

        |SKIP ->  StateConfig (st,hp)
        |_-> raise (Excpetion "transition error in squential control, this should never happen")

    );
    |Parallelism subn ->(
      match subn with
        |Para  ({raw=CmdN subcmd1;  scope=keepScope1},{raw=CmdN subcmd2;  scope=keepScope2}) ->
          if (Random.bool()) then
            (match transition (Cmd subcmd1) st hp with
            |ControlStateConfig (Cmd cmdn,(st1,hp1))-> ControlStateConfig (Cmd (Parallelism (Para ({raw=CmdN cmdn;  scope=keepScope1},{raw=CmdN subcmd2;  scope=keepScope2}))),(st1,hp1))
            |StateConfig (st1,hp1)-> ControlStateConfig (Cmd subcmd2,(st1,hp1))
            |ERROR->ERROR)
          else
            (match transition (Cmd subcmd2) st hp with
            |ControlStateConfig (Cmd cmdn,(st1,hp1))-> ControlStateConfig (Cmd (Parallelism (Para ({raw=CmdN subcmd1;  scope=keepScope1},{raw=CmdN cmdn;  scope=keepScope2}))),(st1,hp1))
            |StateConfig (st1,hp1)-> ControlStateConfig (Cmd subcmd1,(st1,hp1))
            |ERROR->ERROR)

        |Atom {raw=CmdN cmdN;  scope=keepScope1} ->
          (* the atomic transition, repeat the transition until terminate *)
          (*used for "atom" in parallelism control flow *)
          let rec atom_transition control st hp =
            (let config = transition control st hp in
              match config with
                |ControlStateConfig (ctl,(st1,hp1))-> atom_transition ctl st1 hp1
                |StateConfig config1 -> StateConfig config1
                |ERROR -> ERROR) in atom_transition (Cmd cmdN) st hp

        |_-> raise (Excpetion"transition error in parallelism, this should never happen")
      )

    |Block {raw=CmdN subcmd;  scope=keepScope} ->
      (match transition (Cmd subcmd) st hp with
      |ControlStateConfig (Cmd newCmdn,(st1,hp1))-> ControlStateConfig (Cmd (Block ({raw=CmdN newCmdn;  scope=keepScope})),(st1,hp1))
      |StateConfig (Decl env::st1,hp1)-> StateConfig ((st1,hp1))
      |StateConfig (Call (env,st2)::st1,hp1)-> StateConfig ((st2,hp1))
      |ERROR -> ERROR
      |_->raise (Excpetion "transition error in block "))

    |Print {raw=Expn exp1;  scope=keepScope1} ->
       let e1 = eval exp1 st hp in
        let str = printTva e1 in
          if (mode == 0) then print_string (str^"\n") else cumPrint :=!cumPrint^" "^str ^ " ";
          StateConfig(st,hp)
    |_->raise (Excpetion "error semantics transition, this should never happen")
  )
