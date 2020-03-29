type t = {
  lower: int option;
  upper: int option;
  group: int option; 
}

val parse_line : string -> Riscv.t 
(** Given a line from the log, produces a well-formed RISC-V instruction *)

val from_stdin : t -> (Riscv.t Buffer.t, int) Hashtbl.t
(** Parses a log file from stdin - should be used by piping "spike -l $pk executable.out" to it *)