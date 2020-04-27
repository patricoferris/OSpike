type compare = Instr | Instr_Reg | Full
type impl = Iregex | Istring 

type t = {
  lower: int option;
  upper: int option;
  group: int; 
  compare_mode: compare;
  implementation: impl;
}

val impl_to_string : impl -> string
val impl_from_string : string -> impl 
val to_string : t -> string 