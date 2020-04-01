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
[@@deriving compare, sexp, hash]

val unknown : t 
(** Unknown instruction type *)

val instr_of_match: Re2.Match.t -> t 
(** Takes a match from the parser (regex) and returns an instruction *)

val print_instr : out_channel -> t -> Parser_options.compare -> unit 
(** Prints a RISC-V instruction *)

val compare : Parser_options.compare -> t -> t -> int 
(** Custom compare function to work with the hash function *)

val hash : Parser_options.compare -> t -> int 
(** Custom hash function for only checking instruction name and registers *)