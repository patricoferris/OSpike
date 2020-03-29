type t = {
  lower: int option;
  upper: int option;
  group: int; 
}

val parse_line : string -> Riscv.t 
(** Given a line from the log, produces a well-formed RISC-V instruction *)

val from_stdin : t -> (Riscv.t Buffer.t, int) Hashtbl.t
(** Parses a log file from stdin - should be used by piping "spike -l $pk executable.out" to it *)

val add_to_table : ('a, int) Hashtbl.t -> 'a -> unit 
(** Adds an instruction to the hashtable incrementing (or initialising) the frequency *)

val print_sorted : out_channel -> (Riscv.t Buffer.t, int) Hashtbl.t -> t -> unit 
(** Prints the contents of the hashtable in sorted order *)