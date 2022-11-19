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

let initCmd = match startNode.raw with 
  |Start {raw=CmdN cmdn; scope=_} -> cmdn
  |_-> raise (Excpetion "initCmd error");;


let initConfig = ControlStateConfig( (Cmd initCmd), ([],[]) )
let config = ref initConfig
let terminate = ref true;;


let getNewObj () = 
  heapCounter := !heapCounter+1;
  Obj !heapCounter 

  
let printTva (tva:tva) = match tva with
| Error-> "Tva Error"
| Value v -> match v with
  |FldVal (Fld fld) -> fld
  |IntVal (Num num) -> string_of_int num
  |CloVal(Clo (varName,_,_)) -> "proc "^varName^":Commands"
  |LocVal loc -> (match loc with
    |ObjLoc (Obj obj)-> "["^ string_of_int obj^ "]"
    |NULL -> "null"
    )

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
      acc^(List.fold_left (fun acc cur -> acc^"\t\t"^ match cur with
      |((Obj _,Fld fld),tva) -> fld^ "\t| "^ printTva tva^"\n"^"\t\t--------+--------------\n" )
       ("Object_ID_"^(string_of_int key)^"\tfield\t| value\n"^"\t\t--------+--------------\n") fields)^"\n"
  )!keys "\n-------------------------------------------\nCurrent Heap\n-------------------------------------------\n" in heap^"-------------------------------------------\n";;


(* test the print of heap and stack*)
let test_print_heap () = 
  let h1 = [((Obj 0, Fld "name"),Value(FldVal(Fld "Jeffery")));((Obj 0, Fld "gpa"),Value(IntVal(Num 4)));
  ((Obj 0, Fld "address"),Value(FldVal(Fld "foo")));((Obj 1, Fld "name"),Value(FldVal(Fld "Mike")));((Obj 2, Fld "name"),Value(FldVal(Fld "Alice")));
  ((Obj 1, Fld "gpa"),Value(FldVal(Fld "3.8")));((Obj 0, Fld "age"),Value(FldVal(Fld "19")));((Obj 2, Fld "address"),Value(FldVal(Fld "Jeffery")))] in
  print_string (printHeap h1);
;;


test_print_heap()