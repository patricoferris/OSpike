type 'a t = { mutable capacity : int ; data: 'a Queue.t }

let create n = { capacity = n; data = Queue.create () }

let get_size buff = Queue.length buff.data

let pop buff = 
  if get_size buff = 0 then None else 
    Some (Queue.pop buff.data)

let push el buff = 
  if get_size buff = buff.capacity then let _drop = pop buff in Queue.push el buff.data
  else Queue.push el buff.data 

let copy buff = { capacity = buff.capacity; data = Queue.copy buff.data }

let is_empty buff = Queue.is_empty buff.data
let is_full buff = Queue.length buff.data = buff.capacity

let print_buffer print buff = 
  Queue.iter (fun el -> print el) buff.data

let get_data buff = buff.data