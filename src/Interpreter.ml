open Transition
open Domain
open Decoration
open AST

let theControl = ref (Cmd initCmd)
let theStack = ref []

let theHeap = ref [];;

let continue = ref true
let once () = 
  match(transition !theControl !theStack !theHeap) with
  |ControlStateConfig (ctl,(st,hp)) -> 
    theControl := ctl;
    theStack :=st;
    theHeap :=hp
  |StateConfig (st,hp)-> 
    theStack :=st;
    theHeap :=hp;
    terminate := false;
    print_string "terminate"
  |_->raise (Excpetion "error in iterator");; 



while !terminate do
  once();
  print_string (printHeap !theHeap);
  let cmdnode = match !theControl with |Cmd cmdn->cmdn in
  testPrint ({raw=CmdN cmdnode;  scope=TBDscope});
done