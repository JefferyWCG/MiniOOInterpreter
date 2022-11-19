  let getvalue x symtable=
    if (List.mem_assoc x symtable) then 
      Some (List.assoc x symtable)
    else
      None;;

  let rec except x l = match l with
    []   -> []
  | h::t -> if (h = x) then t
              else h::(except x t)

  let setvalue x v symtable=
    if (List.mem_assoc x symtable) then
      (x, v) :: (except (x, (List.assoc x symtable)) symtable)
    else 
      (x, v) :: symtable 
      


