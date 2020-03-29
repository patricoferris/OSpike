let add_to_table freq_tbl instr_group =
  try let f = (Hashtbl.find freq_tbl instr_group) in
    Hashtbl.replace freq_tbl instr_group (f + 1)
  with Not_found -> Hashtbl.add freq_tbl instr_group 1

let print_sorted tbl = 
  let key_values = List.sort (fun (_, v1) (_, v2) -> -Pervasives.compare v1 v2) (List.of_seq (Hashtbl.to_seq tbl)) in 
  let print_kv (k, v) = Riscv.print_instr_group stdout k; print_endline (": " ^ (string_of_int v)) in 
    List.iter print_kv key_values; print_endline ("Total Number of Instructions: " ^ string_of_int ((List.fold_left (fun acc (_k, v) -> acc + v) 0 key_values)))