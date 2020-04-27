type compare = Instr | Instr_Reg | Full
type impl = Iregex | Istring 

type t = {
  lower: int option;
  upper: int option;
  group: int; 
  compare_mode: compare;
  implementation: impl;
}

let compare_to_string = function 
  | Full -> "full hash and compare (including address)"
  | Instr -> "instruction name"
  | Instr_Reg -> "instruction and registers"

let impl_to_string = function 
  | Iregex  -> "regex" 
  | Istring -> "string"

let impl_from_string = function 
  | "string" -> Istring 
  | _ -> Iregex

let to_string options = 
  let int_option_to_string = function 
    | None -> "None"
    | Some i -> string_of_int i
  in
    let g = string_of_int options.group in 
    let c = compare_to_string options.compare_mode in 
    let l = int_option_to_string options.lower in
    let h = int_option_to_string options.upper in
    let p = impl_to_string options.implementation in 
      Printf.sprintf "{ Group Size: %s; Compare_mode: %s; Parser: %s; Range: [%s, %s] }" g c p l h