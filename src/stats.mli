val add_to_table : ('a, int) Hashtbl.t -> 'a -> unit 
(** Adds an instruction to the hashtable incrementing (or initialising) the frequency *)

val print_sorted : (Riscv.t Buffer.t, int) Hashtbl.t -> unit 
(** Prints the contents of the hashtable in sorted order *)