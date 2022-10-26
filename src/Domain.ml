(* File Domain.ml *)
open Decoration

type nums = Num of int
type bools = True | False | Error
let heapCounter = ref 0 (* used for generate unique identifier for location in the heap*)
type obj = Obj of int
type fld = Fld of string
type loc = ObjLoc of obj | NULL
and clo = Clo of (value * control * state)
and value = FldVal of fld | IntVal of nums | LocVal of loc | Clo
and tva = Value of value | Error
and env = (string * obj) list
and frame = Decl of env | Call of (env * stack)
and stack = frame list
and heap = ( (obj*fld) * tva ) 
and state = (stack * heap)
and control = Cmd of AST.cmdn| Block of AST.cmdn
and configuration = ControlStateConfig of (control * state) | StateConfig of state | ERROR;;

Decoration.testPrint ()


