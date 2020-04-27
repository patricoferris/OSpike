module type RiscvComparator = sig 
  val compare : Riscv.t -> Riscv.t -> int 
  val hash : Riscv.t -> int 
end 

module type HashableBuffer = sig 
  include Core.Hashtbl.Key with type t = Riscv.t Buff.t
  val copy : t -> t 
end

module MakeHashableBuffer (C : RiscvComparator) : HashableBuffer

module type LineParser = sig 
  val parse_line : string -> Riscv.t 
  (** Given a line from the log, produces a well-formed RISC-V instruction *)
end 

module type S = sig 
  include LineParser

  val from_stdin : Parser_options.t -> (Riscv.t Buff.t, int) Core.Hashtbl.t
  (** Parses a log file from stdin - should be used by piping "spike -l $pk executable.out" to it *)

  val add_to_table : ('a, int) Core.Hashtbl.t -> 'a -> unit 
  (** Adds an instruction to the hashtable incrementing (or initialising) the frequency *)

  val print_sorted : out_channel -> (Riscv.t Buff.t, int) Core.Hashtbl.t -> Parser_options.t -> unit 
  (** Prints the contents of the hashtable in sorted order *)
end 

val parsers : (string, (module S)) Core.Hashtbl.t 
(** A hashtble of implementations using first-class modules - à la https://caml.inria.fr/pub/docs/manual-ocaml/firstclassmodules.html *)