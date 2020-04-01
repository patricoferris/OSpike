open Core 

type t = {
  instr_name: String.t; 
  arg1: reg option; 
  arg2: reg option; 
  arg3: reg option;
  address: addr option;
  opcode: int option;
}
  and addr = int
  and reg = string 
[@@deriving compare, sexp, hash]

module R = Re2
module M = R.Match
module P = Parser_options

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

let print_instr oc instr = function 
  | Parser_options.Instr -> Printf.fprintf oc "(%s)" instr.instr_name
  | Parser_options.Instr_Reg -> 
    let s_list = [instr.instr_name; (string_of_option instr.arg1); (string_of_option instr.arg2); (string_of_option instr.arg3)] in 
    let s = String.concat ~sep:" " s_list in 
      Printf.fprintf oc "(%s)" s

let compare = function 
  | P.Instr -> 
    fun a b -> String.compare a.instr_name b.instr_name
  | P.Instr_Reg ->   
    fun a b ->
      let instr1 = [a.instr_name; string_of_option a.arg1; string_of_option a.arg2; string_of_option a.arg3] in 
      let instr2 = [b.instr_name; string_of_option b.arg1; string_of_option b.arg2; string_of_option b.arg3] in 
        List.compare (String.compare) instr1 instr2

let hash = function 
  | P.Instr -> 
    fun instr -> Hashtbl.hash instr.instr_name
  | P.Instr_Reg ->   
    fun instr ->
      let h = Hashtbl.hash in 
        (h instr.instr_name) + (h instr.arg1) + (h instr.arg2) + (h instr.arg3)