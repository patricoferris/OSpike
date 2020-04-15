open Core 

module BuffQueue : sig
  include Queue.S
  val compare : ('a -> 'a -> int) -> 'a t -> 'a t -> int 
  val create : ?capacity:int -> unit -> 'a t
  val hash_fold_t : (Hash.state -> 'a -> Hash.state) -> Hash.state -> 'a t -> Hash.state
end 

type 'a t = { capacity : Int.t; data: 'a BuffQueue.t } 
[@@deriving compare, sexp, hash]

val create : int -> 'a t 
(** Creates a new buffer with a max capacity *)

val push : 'a -> 'a t -> unit 
(** Adds new item to back of buffer - will drop items if capacity is reached *)

val pop : 'a t -> 'a option
(** Pops an item from the buffer - if empty returns none *)

val is_empty : 'a t -> bool 
(** Checks for the size of the buffer *)

val is_full : 'a t -> bool 
(** Checks to see if data size is equal to capacity size *)

val print_buffer : ('a -> unit) -> 'a t -> unit 
(** Prints the elements of the buffer *)

val copy : 'a t -> 'a t 
(** Creates a copy of the data *)

val get_size : 'a t -> int 
(** Gets the length of the underlying queue *)

val get_data : 'a t -> 'a BuffQueue.t
(** Extract the underlying queue *)