open Core 

type t = {
  instr_name: String.t; 
  arg1: reg option; 
  arg2: reg option; 
  arg3: reg option;
  address: addr;
  opcode: int;
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
  address = 42;
  opcode = 42;
}

let int_of_hexstring : string option -> int = function 
  | None -> 42 
  | Some str -> int_of_string str

let strip_string_opt : string option -> string option = function 
  | None     -> None 
  | Some str -> Some (Core.String.strip str)

let name = function 
  | None   -> "unknown"
  | Some s -> s  

(* Extracts up to two arguments *)
let extract_args args = 
  let rec aux = function 
    | (0, _) -> [] 
    | (n, []) -> None :: aux (n - 1, [])
    | (n, x::xs) -> strip_string_opt (Some x) :: aux (n - 1, xs)
  in 
  match aux (2, args) with 
    | a::b::[] -> Some (a, b)
    | _ -> None

let instr_of_string str = 
  match String.split_on_chars str ~on:[','] with 
    | [] -> unknown 
    | hd::args -> 
      let meta = String.split_on_chars hd ~on:[' '] in 
      let address = int_of_hexstring (Stdlib.List.nth_opt meta 4) in 
      let brack_op = Stdlib.List.nth meta 5 in 
      let opcode = int_of_hexstring (Some (Stdlib.(String.sub brack_op 1 (String.length brack_op - 2)))) in
      let instr_name = Stdlib.List.nth meta 6 in 
      let arg1 = Stdlib.List.nth_opt meta (List.length meta - 1) in 
      let arg1 = if Some instr_name = arg1 then None else strip_string_opt arg1 in 
        match extract_args args with 
          | Some (arg2, arg3) -> { instr_name; arg1; arg2; arg3; opcode; address }
          | None -> unknown

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
  | Parser_options.Full  -> 
    let instr_list = [(Printf.sprintf "%0#16x" instr.address); instr.instr_name; (string_of_option instr.arg1); (string_of_option instr.arg2); (string_of_option instr.arg3)] in 
    let s = String.concat ~sep:" " instr_list in 
      Printf.fprintf oc "(%s)" s
  | Parser_options.Instr -> Printf.fprintf oc "(%s)" instr.instr_name
  | Parser_options.Instr_Reg -> 
    let s_list = [instr.instr_name; (string_of_option instr.arg1); (string_of_option instr.arg2); (string_of_option instr.arg3)] in 
    let s = String.concat ~sep:" " s_list in 
      Printf.fprintf oc "(%s)" s

let to_string instr = 
  let instr_list = [(Printf.sprintf "%0#16x" instr.address); instr.instr_name; (string_of_option instr.arg1); (string_of_option instr.arg2); (string_of_option instr.arg3)] in 
    String.concat ~sep:" " instr_list

let compare = function 
  | P.Full  -> 
    fun a b -> compare a b 
  | P.Instr -> 
    fun a b -> String.compare a.instr_name b.instr_name
  | P.Instr_Reg ->   
    fun a b ->
      let instr1 = [a.instr_name; string_of_option a.arg1; string_of_option a.arg2; string_of_option a.arg3] in 
      let instr2 = [b.instr_name; string_of_option b.arg1; string_of_option b.arg2; string_of_option b.arg3] in 
        List.compare (String.compare) instr1 instr2

let hash = function 
  | P.Full -> 
    fun instr -> Hashtbl.hash instr 
  | P.Instr -> 
    fun instr -> Hashtbl.hash instr.instr_name
  | P.Instr_Reg ->   
    fun instr ->
      let h = Hashtbl.hash in 
        (h instr.instr_name) + (h instr.arg1) + (h instr.arg2) + (h instr.arg3)