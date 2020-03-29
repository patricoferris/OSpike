(* Shape of a line in the log
 * core 0:<address> (<opcode>) <instr_name> <rd> <rs1> <rs2_or_imm_or_none> 
 * e.g. core   0: 0x0000000000021930 (0xfef41ae3) bne     s0, a5, pc - 12 *)

type t = {
  lower: int option;
  upper: int option;
  group: int; 
}

let instr_regex = Re2.create_exn "core[\\s]+0:\\s(?P<address>[0-9abcdefx]+)[\\s]+\\((?P<opcode>[0-9abcdefx]+)\\)\\s(?P<instr>[\\w\\.]+)[\\s]+(?P<first>[\\w\\s\\(\\)]+),[\\s]+(?P<second>[\\w\\s\\(\\)]+)[,]*(?P<third>[\\w\\s-\\(\\)]+)*"

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
  try let f = (Hashtbl.find freq_tbl instr_group) in
    Hashtbl.replace freq_tbl instr_group (f + 1)
  with Not_found -> Hashtbl.add freq_tbl instr_group 1

let add_instruction buff tbl str = 
  let instr = parse_line str in 
  let _ = Buffer.push instr buff in 
    if Buffer.is_full buff then add_to_table tbl (Buffer.copy buff)

let print_sorted oc tbl options = 
  let key_values = List.sort (fun (_, v1) (_, v2) -> -Pervasives.compare v1 v2) (List.of_seq (Hashtbl.to_seq tbl)) in 
  let print_kv (k, v) = Riscv.print_instr_group oc k; Printf.fprintf oc "%s\n" (": " ^ (string_of_int v)) in 
    List.iter print_kv key_values; Printf.fprintf oc "\n%s\n" ("Total Number of Instructions: " ^ string_of_int ((List.fold_left (fun acc (_k, v) -> acc + v) 0 key_values) + options.group - 1 ))

let from_stdin options = 
  let buffer = Buffer.create options.group in 
  let freq_tbl = Hashtbl.create 100 in
  let _s = read_stream (add_instruction buffer freq_tbl) 1 stdin in 
    freq_tbl