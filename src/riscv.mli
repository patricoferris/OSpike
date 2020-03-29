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

val unknown : t 
(** Unknown instruction type *)

val instr_of_match: Re2.Match.t -> t 
(** Takes a match from the parser (regex) and returns an instruction *)

val print_instr : out_channel -> t -> unit 
(** Prints a RISC-V instruction *)

val print_instr_group : out_channel -> t Buffer.t -> unit 
(** Prints a RISC-V instruction group *)