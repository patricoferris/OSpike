open Core 

module BuffQueue = struct 
  include Core.Queue 
  let hash_fold_t f s q = List.hash_fold_t f s (Queue.to_list q)
end 

type 'a t = { capacity : Int.t ; data: 'a BuffQueue.t } [@@deriving compare, sexp, hash]

let create n = { capacity = n; data = BuffQueue.create () }

let get_size buff = BuffQueue.length buff.data

let pop buff = 
  if get_size buff = 0 then None else 
    BuffQueue.dequeue buff.data

let push el buff = 
  if get_size buff = buff.capacity then let _drop = pop buff in BuffQueue.enqueue buff.data el
  else BuffQueue.enqueue buff.data el

let copy buff = { capacity = buff.capacity; data = BuffQueue.copy buff.data }

let is_empty buff = BuffQueue.is_empty buff.data
let is_full buff = BuffQueue.length buff.data = buff.capacity

let print_buffer print buff = 
  BuffQueue.iter ~f:(fun el -> print el) buff.data

let get_data buff = buff.data
let hash_fold_t f s b = BuffQueue.hash_fold_t f s (get_data b)