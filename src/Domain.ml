(* semantic domains and helper functions *)
open Decoration
open AST

type nums = Num of int
type bools = True | False | Error
type obj = Obj of int  (* this is stored as integer *)
type fld = Fld of string
type loc = ObjLoc of obj | NULL
and clo = Clo of (string * control * stack)
and value = FldVal of fld | IntVal of nums | LocVal of loc | CloVal of clo
and tva = Value of value | Error
and env = (string * obj) list
and frame = Decl of env | Call of (env * stack)
and stack = frame list
and heap = ( (obj*fld) * tva ) list
and state = (stack * heap)
and control = Cmd of cmdn
and configuration = ControlStateConfig of (control * state) | StateConfig of state | ERROR;;
exception Excpetion of string



let heapCounter = ref 0
let cumPrint = ref ""
let initCmd = match startNode.raw with
  |Start {raw=CmdN cmdn; scope=_} -> cmdn
  |_-> raise (Excpetion "initCmd error");;


let initConfig = ControlStateConfig( (Cmd initCmd), ([],[]) )
let config = ref initConfig
let terminate = ref false

let printSpace = ref ""


let getNewObj () =
  heapCounter := !heapCounter+1;
  Obj !heapCounter

let rec getFromEnv varName (env:env) =
if (List.mem_assoc varName env) then
  Some (List.assoc varName env)
else None
let rec getFromStack varName st = match st with
  | [] -> raise (Excpetion "stack search error")
  | h::t -> match(
    let envr = (match h with
    |Decl env -> env
    |Call (env,_) -> env) in getFromEnv varName envr
  ) with
  |Some obj -> obj
  |None -> getFromStack varName t

;;
let getfromHeap obj fld (hp:heap) =  List.assoc (obj,fld) hp
let isInHeapDomain  obj fld (hp:heap) = List.mem_assoc (obj,fld) hp

let setHeap obj fld tva (hp:heap) =
  if (isInHeapDomain obj fld hp)
    then List.map (
    fun ((o,f),t)->
      if (o = obj&& f=fld)
        then ((obj,fld),tva)
        else ((o,f),t)
      ) hp
  else ((obj,fld),tva)::hp

let getVar varName (st:stack) hp = getfromHeap (getFromStack varName st) (Fld "val") hp

let isLocationInHeap tva (hp:heap) =
   match tva with
   |Value (LocVal (ObjLoc(Obj obj)))->
    List.fold_left (fun acc ((Obj obj1,_),_) -> if obj = obj1 then true else acc) false hp
   |_-> false

let isField tva (hp:heap) =
  match tva with
  |Value (FldVal Fld fld)->true
  |_-> false

let isNum tva (hp:heap) =
  match tva with
  |Value (IntVal Num n)->true
  |_-> false

let isLocation tva (hp:heap) =
  match tva with
  |Value (LocVal n)->true
  |_-> false

  let isClosure tva (hp:heap) =
    match tva with
    |Value (CloVal n)->true
    |_-> false

let getObjFromTva tva (hp:heap) =
  if not (isLocationInHeap tva hp) then raise (Excpetion "can't cast to an object")
  else   match tva with
  |Value (LocVal (ObjLoc (obj)))->  obj
  |_-> raise (Excpetion "getObjFromTva error")

let getFldFromTva tva (hp:heap) =
  if not (isField tva hp) then raise (Excpetion "can't cast to a field")
  else    match tva with
  |Value (FldVal fld)->fld
  |_-> raise (Excpetion "getFldFromTva error")

let getNumFromTva tva (hp:heap) =
  if not (isNum tva hp) then raise (Excpetion "can't cast to a field")
  else    match tva with
  Value (IntVal Num n)->n
  |_-> raise (Excpetion "getFldFromTva error")

let paddingEmpty str n= let l = String.length str and padding = ref "" in for i=l  to n
  do
    padding := !padding^" "
  done;
  !padding


let printTva (tva:tva) = match tva with
| Error-> "Undefined"
| Value v -> match v with
  |FldVal (Fld fld) -> fld
  |IntVal (Num num) -> string_of_int num
  |CloVal(Clo (varName,_,_)) -> "Closure("^varName^" ...)"
  |LocVal loc -> (match loc with
    |ObjLoc (Obj obj)-> "object_ID_"^ string_of_int obj
    |NULL -> "null"
    )


let printHeap (hp:heap) =
  let myHash = Hashtbl.create 123456
  and keys = ref [] in
  List.fold_left
  (fun acc cur ->
    let key = (match cur with |(((Obj obj),_),_)-> obj) in
    Hashtbl.add myHash key cur;
    if(List.mem key !keys = false) then keys := key::!keys else keys := !keys;
    ()
  ) () hp;
  let heap = List.fold_right
  (fun key acc->
    let fields = Hashtbl.find_all myHash key in
      acc^(List.fold_left (fun acc cur -> acc^""^ match cur with
      |((Obj _,Fld fld),tva) -> paddingEmpty "" 17^fld^ paddingEmpty fld 10^"| "^ printTva tva^"\n"^paddingEmpty "" 14^"--------------+-------------------\n" )
       ("Object_ID_"^(string_of_int key)^"      field       | value\n"^paddingEmpty "" 14^"--------------+-------------------\n") fields)^"\n"
  )!keys "Current Heap\n-------------------------------------------------------\n" in heap^"----------------------------------------------------\n";;




let printStack (st:stack) = let line = "+----------+---------------+----------------+" in
List.fold_right (
  fun cur acc-> acc ^ (match cur with
    |Decl [(varName,Obj objID)]-> "| Declare  | "^varName^(paddingEmpty varName 13)^"| Object_ID_"^string_of_int objID^ paddingEmpty (string_of_int objID) 4^"|"
    |Call ([(varName,Obj objID)],_)-> "| Call     | "^varName^(paddingEmpty varName 13)^"| Object_ID_"^string_of_int objID^ paddingEmpty (string_of_int objID) 4^"|"
    |_->  raise (Excpetion "error in printing stack")
    ) ^"\n"^line^"\n"
  ) st ("Current Stack:\n"^line^"\n| type     | variable name | location       |\n"^line^"\n")
(* test the print of heap and stack*)


let test_print_heap () =
  let h1 = [((Obj 0, Fld "name"),Value(FldVal(Fld "Jeffery")));((Obj 0, Fld "gpa"),Value(IntVal(Num 4)));
  ((Obj 0, Fld "address"),Value(FldVal(Fld "foo")));((Obj 1, Fld "name"),Value(FldVal(Fld "Mike")));((Obj 2, Fld "name"),Value(FldVal(Fld "Alice")));
  ((Obj 1, Fld "gpa"),Value(FldVal(Fld "3.8")));((Obj 0, Fld "age"),Value(FldVal(Fld "19")));((Obj 2, Fld "address"),Value(FldVal(Fld "Jeffery")))] in
  print_string (printHeap h1);
;;

