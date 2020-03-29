open Ospike

let equal_buffer a b = a = b
let pp_buffer ppf buffer = Fmt.pf ppf "Buffer: %s" (Queue.fold (fun acc i -> acc ^ (string_of_int i)) "" (Buffer.get_data buffer))

let buffer_testable = Alcotest.testable pp_buffer equal_buffer

let test_create () = 
  let buffer1 = Buffer.create 1 in
  let _ = Buffer.push 10 buffer1 in 
  let q = Queue.create () in 
  let _ = Queue.push 10 q in 
  let buffer2 : int Buffer.t = { capacity = 1; data = q } in 
    Alcotest.check buffer_testable "Same buffers" buffer1 buffer2

let test_push_pop () = 
  let buff = Buffer.create 2 in 
  let _ = Buffer.push 1 buff; Buffer.push 2 buff in 
  let first = Buffer.pop buff in 
  let second = Buffer.pop buff in 
    Alcotest.(check (option int)) "same first ints" (Some 1) first; 
    Alcotest.(check (option int)) "same second ints" (Some 2) second

let test_push_and_drop () = 
  let buff = Buffer.create 2 in 
  let _ = Buffer.push 1 buff; Buffer.push 2 buff; Buffer.push 3 buff in 
  let two = Buffer.pop buff in 
  let three = Buffer.pop buff in 
    Alcotest.(check (option int)) "same first ints" (Some 2) two; 
    Alcotest.(check (option int)) "same second ints" (Some 3) three

let test_pop_none () = 
  let buff = Buffer.create 1 in 
  let _ = Buffer.push 1 buff in 
  let none = ignore (Buffer.pop buff); Buffer.pop buff in 
    Alcotest.(check (option int)) "none" None none

let () = 
  Alcotest.run "Buffer Tests"
    [ ( "Buffer", 
      [ Alcotest.test_case "Create new buffer" `Quick test_create;
        Alcotest.test_case "Queue semantics" `Quick test_push_pop;
        Alcotest.test_case "Drop entries over capacity" `Quick test_push_and_drop;
        Alcotest.test_case "Return none from empty buffer" `Quick test_pop_none ])]