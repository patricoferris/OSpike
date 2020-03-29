type t = {
  instr_name: string; 
  arg1: reg option; 
  arg2: reg option; 
  arg3: reg option;
  address: addr option;
  opcode: int option;
}
  and addr = int
  and reg = string 

module R = Re2
module M = R.Match

let unknown = {
  instr_name = "Unknown Instruction";
  arg1 = None; 
  arg2 = None; 
  arg3 = None;
  address = None;
  opcode = None;
}

let int_of_hexstring = function 
  | None -> None 
  | Some str -> Some (int_of_string str)

let name = function 
  | None   -> "unknown"
  | Some s -> s  

let instr_of_match matching = 
  let address = int_of_hexstring (M.get ~sub:(`Name "address") matching) in 
  let opcode  = int_of_hexstring (M.get ~sub:(`Name "opcode") matching) in 
  let instr_name = name (M.get ~sub:(`Name "instr") matching) in 
  let arg1 = (M.get ~sub:(`Name "first") matching) in 
  let arg2 = (M.get ~sub:(`Name "second") matching) in 
  let arg3 = (M.get ~sub:(`Name "third") matching) in 
    { instr_name; arg1; arg2; arg3; opcode; address }

let string_of_option = function 
  | None   -> "none"
  | Some s -> s 

let print_instr oc instr = 
  let s_list = [instr.instr_name; (string_of_option instr.arg1); (string_of_option instr.arg2); (string_of_option instr.arg3)] in 
  let s = String.concat " " s_list in 
    Printf.fprintf oc "(%s)" s

let print_instr_group oc buff =
  Buffer.print_buffer (print_instr oc) buff 
  (* List.iter (fun instr -> print_instr oc instr; print_string " ") lst  *)