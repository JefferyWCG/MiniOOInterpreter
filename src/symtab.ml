(* File symtab.ml *)

type numOrFld = Int of int | FLD of string | NULL

type symbTable =(string * numOrFld) list ;;


type scopeAtrb ={ v:symbTable; e:bool }

let getvalue x symtable=
   if (List.mem_assoc x symtable) then 
     Some (List.assoc x symtable)
   else
     None;;

let rec except (x:(string * numOrFld)) l = match l with
  []   -> []
| h::t -> if (h = x) then t
            else h::(except x t)

(*set the v field in x in symtable*)            
let setvalue x v symtable=
   if (List.mem_assoc x symtable) then
    (x, v) :: (except (x, (List.assoc x symtable)) symtable)
   else 
    (x, v) :: symtable 
    

let tab = [("a",Int 2);("b",Int 10);("c",FLD "foo")]
let  x ={v=tab;e=true}







