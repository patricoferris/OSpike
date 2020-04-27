open Ospike_lib

let equal_riscv_instr a b = a = b
let pp_riscv ppf instr = Fmt.pf ppf "Instruction: %s" (Riscv.to_string instr)

let instr_testable = Alcotest.testable pp_riscv equal_riscv_instr

let test_regex () = 
  let log_instr = "core   0: 0x0000000000021928 (0x0000953e) c.add   a0, a5" in
  let instr_name = "c.add" in 
  let arg1 = Some "a0" in 
  let arg2 = Some "a5" in 
  let arg3 = None in 
  let opcode = 0x0000953e in 
  let address = 0x0000000000021928 in 
  let correct : Riscv.t =  { instr_name; arg1; arg2; arg3; opcode; address } in
  let module P = (val (Core.Hashtbl.find_exn Parser.parsers "regex")) in 
  let instr = P.parse_line log_instr in 
    Alcotest.(check instr_testable) "same instruction" correct instr

let test_string () = 
  let log_instr = "core   0: 0x0000000000021928 (0x0000953e) c.add   a0, a5" in
  let instr_name = "c.add" in 
  let arg1 = Some "a0" in 
  let arg2 = Some "a5" in 
  let arg3 = None in 
  let opcode = 0x0000953e in 
  let address = 0x0000000000021928 in 
  let correct : Riscv.t =  { instr_name; arg1; arg2; arg3; opcode; address } in
  let module P = (val (Core.Hashtbl.find_exn Parser.parsers "string")) in 
  let instr = P.parse_line log_instr in 
    Alcotest.(check instr_testable) "same instruction" correct instr

let test_adding_to_table () = 
  let tbl = Base.(Hashtbl.create (module String)) in 
  let module P = (val (Core.Hashtbl.find_exn Parser.parsers "regex")) in 
  let _ : unit = P.add_to_table tbl "World" in 
  let _ : unit = P.add_to_table tbl "Hello" in 
  let _ : unit = P.add_to_table tbl "Hello" in 
  let (c, d) = Base.((Hashtbl.find tbl "World",(Hashtbl.find tbl "Hello"))) in match (c, d) with 
    | Some m, Some n -> Alcotest.(check int) "counting hellos" 2 n; Alcotest.(check int) "counting worlds" 1 m
    | _ -> assert false 
    

let () = 
  Alcotest.run "Parser Tests"
    [ ( "Parser", 
      [ Alcotest.test_case "Parse instruction with regex" `Quick test_regex;
        Alcotest.test_case "Parse instruction with string" `Quick test_string;
        Alcotest.test_case "Adding items to table" `Quick test_adding_to_table])]