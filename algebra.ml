type col = Col of string | Lit of int
type table = col list
type pred = Equals of col * col
type agg = Sum of col | Count of col | Min of col | Max of col

type query =
    | Table of table
    | Select of pred * query
    | Project of col list * query
    | Union of query * query
    | Join of pred * query * query
    | Group of agg list * col list * query

let string_of_col = function
    | Col s -> s
    | Lit l -> string_of_int l

let string_of_table (t : table) = String.concat ", " (List.map string_of_col t)

let string_of_pred (Equals (c1, c2)) =
    (string_of_col c1) ^ "=" ^ (string_of_col c2)

let string_of_agg = function
    | Sum c -> "Sum(c)"
    | Count c -> "Count(c)"
    | Min c -> "Min(c)"
    | Max c -> "Max(c)"

let string_of_query =
    let make_indent depth = String.make (depth * 4) ' ' in
    let rec f depth = function
        | Table t ->
            Printf.sprintf "𝓕[%s]" (string_of_table t)
        | Select (p, q) ->
            Printf.sprintf "σ[%s  %s]" (string_of_pred p) (f depth q)
        | Project (cl, q) ->
            Printf.sprintf "π[%s  %s]" (string_of_table cl) (f depth q)
        | Union (ql, qr) ->
            Printf.sprintf "∪[\n%s%s\n%s%s]"
            (make_indent depth) (f (depth + 1) ql)
            (make_indent depth) (f (depth + 1) qr)
        | Join (p, ql, qr) ->
            Printf.sprintf "⋈[%s\n%s%s\n%s%s]"
            (string_of_pred p)
            (make_indent depth) (f (depth + 1) ql)
            (make_indent depth) (f (depth + 1) qr)
        | Group (al, cl, q) -> Printf.sprintf "γ[%s  %s]"
            (String.concat ", " ((List.map string_of_agg al) @ (List.map string_of_col cl)))
            (f depth q)
    in f 1


let print_col (c : col) = print_string (string_of_col c)
let print_table (t : table) = print_string (string_of_table t)
let print_pred (p : pred) = print_string (string_of_pred p)
let print_agg (a : agg) = print_string (string_of_agg a)
let print_query (q : query) = print_string (string_of_query q)
