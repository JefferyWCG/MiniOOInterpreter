open Transition
open Domain
open Decoration
open AST

let theControl = ref (Cmd initCmd)

let theStack = ref []

let theHeap = ref [];;

let transition_step_num = ref 0


let transition_step () =
  match(transition !theControl !theStack !theHeap) with
  |ControlStateConfig (ctl,(st,hp)) ->
    theControl := ctl;
    theStack :=st;
    theHeap :=hp;
  |StateConfig (st,hp)->
    theStack :=st;
    theHeap :=hp;
    terminate := true;
    print_string "\nprogram terminates without error"
  |ERROR ->
    print_string "program terminates because of error";
    terminate := true;;


let print_config () =
  print_string ("\n=====================================================================================\nConfiguration after the transition step: "^string_of_int !transition_step_num^"");
  transition_step();
  print_string ("\n=====================================================================================\n\n");
  print_string (printStack !theStack^"\n\n");
  print_string (printHeap !theHeap^"\n");
  if not !terminate then (print_string "current control\n");
  if not !terminate then (let cmdnode = match !theControl with |Cmd cmdn->cmdn in
  testPrint ({raw=CmdN cmdnode;  scope=TBDscope}) false);
  print_string ("\nthe cumulative print-space:\n"^ !cumPrint^"\n");
  print_string ("\n=====================================================================================\n");
  transition_step_num := !transition_step_num+1;
in

while not !terminate do
  if(mode =1) then  print_config() else transition_step();
done
;

(* for mode 0, print the heap upon termination *)

if(mode = 0) then(
print_string ("\n print the heap and stack upon termination");
print_string ("\n=====================================================================================\n\n");
print_string (printStack !theStack^"\n\n");
print_string (printHeap !theHeap^"\n");
)
