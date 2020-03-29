type 'a t = { mutable capacity : int; data: 'a Queue.t }

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

val get_data : 'a t -> 'a Queue.t
(** Extract the underlying queue *)