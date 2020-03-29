(* Shape of a line in the log
 * core 0:<address> (<opcode>) <instr_name> <rd> <rs1> <rs2_or_imm_or_none> 
 * e.g. core   0: 0x0000000000021930 (0xfef41ae3) bne     s0, a5, pc - 12 *)

type t = {
  lower: int option;
  upper: int option;
  group: int option; 
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

let add_instruction buff tbl str = 
  let instr = parse_line str in 
  let _ = Buffer.push instr buff in 
    if Buffer.is_full buff then Stats.add_to_table tbl (Buffer.copy buff)

let from_stdin options = 
  let groups = match options.group with | None -> 1 | Some n -> n in 
  let buffer = Buffer.create groups in 
  let freq_tbl = Hashtbl.create 100 in
  let _s = read_stream (add_instruction buffer freq_tbl) 1 stdin in 
    freq_tbl