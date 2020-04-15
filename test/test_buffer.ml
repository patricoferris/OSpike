open Ospike_lib

module Q = Buff.BuffQueue

let equal_buffer a b = a = b
let pp_buffer ppf buffer = Fmt.pf ppf "Buff: %s" (Q.fold ~f:(fun acc i -> acc ^ (string_of_int i)) ~init:"" (Buff.get_data buffer))

let buffer_testable = Alcotest.testable pp_buffer equal_buffer

let test_create () = 
  let buffer1 = Buff.create 1 in
  let _ : unit = Buff.push 10 buffer1 in 
  let q = Buff.BuffQueue.create () in 
  let _ : unit = Q.enqueue q 10 in 
  let buffer2 : int Buff.t = { capacity = 1; data = q } in 
    Alcotest.check buffer_testable "Same buffers" buffer1 buffer2

let test_push_pop () = 
  let buff = Buff.create 2 in 
  let _ : unit = Buff.push 1 buff; Buff.push 2 buff in 
  let first = Buff.pop buff in 
  let second = Buff.pop buff in 
    Alcotest.(check (option int)) "same first ints" (Some 1) first; 
    Alcotest.(check (option int)) "same second ints" (Some 2) second

let test_push_and_drop () = 
  let buff = Buff.create 2 in 
  let _ : unit = Buff.push 1 buff; Buff.push 2 buff; Buff.push 3 buff in 
  let two = Buff.pop buff in 
  let three = Buff.pop buff in 
    Alcotest.(check (option int)) "same first ints" (Some 2) two; 
    Alcotest.(check (option int)) "same second ints" (Some 3) three

let test_pop_none () = 
  let buff = Buff.create 1 in 
  let _ : unit = Buff.push 1 buff in 
  let none = ignore ((Buff.pop buff) : int option); Buff.pop buff in 
    Alcotest.(check (option int)) "none" None none

let test_copy () = 
  let buff = Buff.create 1 in 
  let copy = Buff.copy buff in 
  let _ : unit = Buff.push 1 buff in 
    Alcotest.(check int) "buff one contains 1" 1 (Buff.get_size buff);
    Alcotest.(check int) "copy contains nothing" 0 (Buff.get_size copy)

let () = 
  Alcotest.run "Buff Tests"
    [ ( "Buff", 
      [ Alcotest.test_case "Create new Buff" `Quick test_create;
        Alcotest.test_case "Queue semantics" `Quick test_push_pop;
        Alcotest.test_case "Drop entries over capacity" `Quick test_push_and_drop;
        Alcotest.test_case "Return none from empty Buff" `Quick test_pop_none;
        Alcotest.test_case "Copying buffers works" `Quick test_copy ])]