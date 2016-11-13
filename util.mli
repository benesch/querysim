val filteri : (int -> 'a -> bool) -> 'a list -> 'a list

val findi : ('a -> bool) -> 'a list -> int

val pop_assoc : 'a -> ('a * 'b) list -> 'b * ('a * 'b) list
