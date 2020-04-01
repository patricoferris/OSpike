type compare = Instr | Instr_Reg 

type t = {
  lower: int option;
  upper: int option;
  group: int; 
  compare_mode: compare
}

let compare_to_string = function 
  | Instr -> "instruction name"
  | Instr_Reg -> "instruction and registers"

let to_string options = 
  let int_option_to_string = function 
    | None -> "None"
    | Some i -> string_of_int i
  in
    let g = string_of_int options.group in 
    let c = compare_to_string options.compare_mode in 
    let l = int_option_to_string options.lower in
    let h = int_option_to_string options.upper in
      Printf.sprintf "{ Group Size: %s; Compare_mode: %s; Range: [%s, %s] }" g c l h