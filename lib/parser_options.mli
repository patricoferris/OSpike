type compare = Instr | Instr_Reg | Full

type t = {
  lower: int option;
  upper: int option;
  group: int; 
  compare_mode: compare
}

val to_string : t -> string 