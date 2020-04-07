(* Shape of a line in the log
 * core 0:<address> (<opcode>) <instr_name> <rd> <rs1> <rs2_or_imm_or_none> 
 * e.g. core   0: 0x0000000000021930 (0xfef41ae3) bne     s0, a5, pc - 12 *)

module Queue = Core.Queue
module Hashtbl = Core.Hashtbl

module type RiscvComparator = sig 
  val compare : Riscv.t -> Riscv.t -> int 
  val hash : Riscv.t -> int 
end 

module type HashableBuffer = sig 
  include Hashtbl.Key with type t = Riscv.t Buff.t
  val copy : t -> t 
end

module MakeHashableBuffer (C : RiscvComparator) = struct 
  type t = Riscv.t Buff.t
  let compare a b = Buff.compare (C.compare) a b 
  let sexp_of_t t = Buff.sexp_of_t Riscv.sexp_of_t t 
  let t_of_sexp s = Buff.t_of_sexp Riscv.t_of_sexp s
  let copy a : t = Buff.copy a 
  let hash buff = Buff.BuffQueue.fold ~f:(fun acc instr -> acc + (C.hash instr)) ~init:0 (Buff.get_data buff)
end

let instr_regex = Re2.create_exn "core[\\s]+0:\\s(?P<address>[0-9abcdefx]+)[\\s]+\\((?P<opcode>[0-9abcdefx]+)\\)\\s(?P<instr>[\\w\\.]+)[\\s]*(?P<first>[\\w\\s\\(\\)]+)[,]*[\\s]*(?P<second>[\\w\\s\\(\\)]+)*[,]*(?P<third>[\\w\\s-\\(\\)]+)*"

let parse_line line = 
  let matching = Re2.first_match instr_regex line in 
  match matching with 
    | Ok instr -> Riscv.instr_of_match instr
    | Error _  -> Riscv.unknown

let _read_lines n ic =
	let rec lines acc = function
		| 0 -> List.rev acc
		| n -> lines ((input_line ic) :: acc) (n - 1)
	in
		lines [] n

let stream_lines _n ic = 
  Stream.from 
    (fun _ -> try Some (input_line (*read_lines n*) ic) with End_of_file -> None)

let read_stream f n ic = 
  Stream.iter (fun lines -> f lines) (stream_lines n ic)

let _check_bounds lower upper current = current >= lower && current <= upper

let add_to_table freq_tbl instr_group =
  let f = (Hashtbl.find freq_tbl instr_group) in match f with 
    | Some n -> Hashtbl.set freq_tbl ~key:instr_group ~data:(n + 1)
    | None   -> Hashtbl.set freq_tbl ~key:instr_group ~data:1

let print_sorted oc tbl (options : Parser_options.t) = 
  let key_values = List.sort (fun (_, v1) (_, v2) -> -Stdlib.compare v1 v2) (Hashtbl.to_alist tbl) in 
  let print_kv (k, v) = Buff.print_buffer (fun i -> Riscv.print_instr oc i options.compare_mode) k; Printf.fprintf oc "%s\n" (": " ^ (string_of_int v)) in 
    List.iter print_kv key_values; Printf.fprintf oc "\n%s\n" ("Total Number of Instructions: " ^ string_of_int ((List.fold_left (fun acc (_k, v) -> acc + v) 0 key_values) + options.group - 1 ))

let from_stdin (options : Parser_options.t) = 
  let lower = options.lower in 
  let upper = options.upper in 
  let module Compare = struct 
    let compare = Riscv.compare options.compare_mode 
    let hash = Riscv.hash options.compare_mode 
  end in 
  let module HB = MakeHashableBuffer(Compare) in 
  let add_instruction buff tbl lower upper str = 
    let instr = parse_line str in 
    begin match (lower, upper) with 
      | (None, None) -> Buff.push instr buff (* ignoring any address range limiting *)
      | (Some l, Some h) when instr.address <= h && instr.address >= l -> print_endline ((string_of_int h) ^ "   " ^ (string_of_int instr.address)); Buff.push instr buff
      | (_, _) -> (Buff.pop buff : Riscv.t option) |> ignore
    end;
    if Buff.is_full buff then add_to_table tbl (HB.copy buff) in 
  let buffer = Buff.create options.group in 
  let freq_tbl = Core.Hashtbl.create (module HB) in
  let _s = read_stream (add_instruction buffer freq_tbl lower upper) 1 stdin in 
    freq_tbl