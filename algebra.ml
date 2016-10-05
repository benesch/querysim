(* Some notes on the design of these data types:
 *
 *     1. All column names must be unique across tables. This is no loss
 *        of generality and simplifies column-equivalence checks because
 *        provenance doesn't matter.
 *     2. Only equijoins are permitted. This is probably no big deal to start.. How
 *        often do theta-joins happen anyway?
 *)

type col = Col of string | Lit of string | Param
type pred = Equal of col * col
type agg = Count | Sum of col | Min of col | Max of col

type query =
    | Table of col list
    | Select of pred list * query
    | Project of col list * query
    | Union of query * query
    | Equijoin of col list * query * query
    | Group of agg list * col list * query

let rec columns = function
    | Table cs -> cs
    | Select (p, q) -> columns q
    | Project (cs, q) -> cs
    | Union (q1, q2) -> columns q1 @ columns q2
    | Equijoin (p, q1, q2) -> columns q1 @ columns q2
    | Group (aggs, cs, q) -> cs

let columns_equal (c1s : col list) (c2s : col list) =
    (List.sort compare c1s) = (List.sort compare c2s)

let valid_column (cs : col list) (c : col) =
    match c with
    | Col _ | Lit _ -> List.mem c cs
    | Param -> true

let rec valid_query = function
    | Table cs ->
        List.for_all (function Col _ -> true | Lit _ -> true | Param -> false) cs
    | Select (ps, q) ->
        let cs = columns q in
        List.for_all
            (fun (Equal (c1, c2)) -> valid_column cs c1 && valid_column cs c2)
            ps
    | Project (cs, q) ->
        let qcs = columns q in
        List.for_all (valid_column qcs) cs
    | Union (q1, q2) ->
        let q1cs = columns q1 in
        let q2cs = columns q2 in
        valid_query q1 && valid_query q2 && columns_equal q1cs q2cs
    | Equijoin (cs, q1, q2) ->
        let q1cs = columns q1 in
        let q2cs = columns q2 in
        List.for_all (fun c -> valid_column q1cs c && valid_column q2cs c) cs
    | Group (aggs, cs, q) ->
        let qcs = columns q in
        List.for_all (valid_column qcs) cs &&
        List.for_all (function Count -> true | Sum c | Min c | Max c -> List.mem c qcs) aggs
;;

let assert_valid (q : query) = assert (valid_query q) ;;
let assert_invalid (q : query) = assert (not (valid_query q)) ;;

assert_valid (Table [Col "a"; Col "b"; Lit "4"]) ;;
assert_invalid (Table [Param]) ;;

assert_valid (Select ([Equal (Col "a", Col "b")], Table [Col "a"; Col "b"])) ;;
assert_invalid (Select ([Equal (Col "a", Col "c")], Table [Col "a"; Col "b"])) ;;

assert_valid (Project ([Col "c"; Col "b"], Table [Col "a"; Col "b"; Col "c"])) ;;
assert_invalid (Project ([Col "c"; Col "d"], Table [Col "a"; Col "b"; Col "c"])) ;;

assert_invalid (Union (Table [Col "a"], Table [Col "b"])) ;;
assert_invalid (Union (Table [Param], Table [Param])) ;;

assert_valid (Group ([Sum (Col "a")], [], Table [Col "a"])) ;;
assert_invalid (Group ([Sum (Col "b")], [], Table [Col "a"])) ;;

let has_param (Equal (c1, c2)) = match (c1, c2) with
    | (_, Param) | (Param, _) -> true
    | _ -> false

let rec push_selects = function
    | Table cs -> Table cs
    | Select (ps, q) ->
        let (stayps, pushps) = List.partition (has_param) ps in
        let innerq = match q with
        | Table _ | Group _ | Project _ -> Select (ps, q)
        | Select (ps', q') ->
            let (stayps', pushps') = List.partition (has_param) ps' in
            Select (stayps @ stayps', push_selects (Select (pushps @ pushps', q')))
        | Union (q1, q2) -> Union (Select (pushps, q1), Select (pushps, q2))
        | Equijoin (cs, q1, q2) ->
            let checkc c cs = match c with
                | Col _ -> List.mem c cs
                | Lit _ -> true
                | Param -> failwith "unexpected param"
            in
            let checkp cs (Equal (c1, c2)) = checkc c1 cs && checkc c2 cs in
            let c1s = columns q1 in
            let c2s = columns q2 in
            let p1s = List.filter (checkp c1s) pushps in
            let p2s = List.filter (checkp c2s) pushps in
            Equijoin (cs, Select (p1s, q1), Select (p2s, q2)) in
        Select (stayps, innerq)
    | Project (cs, q) -> Project (cs, push_selects q)
    | Union (q1, q2) -> Union (push_selects q1, push_selects q2)
    | Equijoin (cs, q1, q2) -> Equijoin (cs, q1, q2)
    | Group (aggs, cs, q) -> Group (aggs, cs, push_selects q)

let string_of_col = function
    | Col s -> s
    | Lit l -> Printf.sprintf "\"%s\"" l
    | Param -> "?"

let string_of_cols (cs : col list) = String.concat ", " (List.map string_of_col cs)

let string_of_pred (Equal (c1, c2)) =
    (string_of_col c1) ^ "=" ^ (string_of_col c2)

let string_of_preds ps = String.concat ", " (List.map string_of_pred ps)

let string_of_agg = function
    | Sum c -> Printf.sprintf "Sum(%s)" (string_of_col c)
    | Count -> "Count"
    | Min c -> Printf.sprintf "Min(%s)" (string_of_col c)
    | Max c -> Printf.sprintf "Max(%s)" (string_of_col c)

let string_of_query =
    let make_indent depth = String.make (depth * 4) ' ' in
    let rec f depth = function
        | Table cs ->
            Printf.sprintf "𝓕[%s]" (string_of_cols cs)
        | Select (ps, q) ->
            Printf.sprintf "σ[%s\n%s%s]"
                (string_of_preds ps) (make_indent depth) (f (depth + 1) q)
        | Project (cs, q) ->
            Printf.sprintf "π[%s  %s]" (string_of_cols cs) (f depth q)
        | Union (q1, q2) ->
            Printf.sprintf "∪[\n%s%s\n%s%s]"
            (make_indent depth) (f (depth + 1) q1)
            (make_indent depth) (f (depth + 1) q2)
        | Equijoin (cs, q1, q2) ->
            Printf.sprintf "⋈[%s\n%s%s\n%s%s]"
            (string_of_cols cs)
            (make_indent depth) (f (depth + 1) q1)
            (make_indent depth) (f (depth + 1) q2)
        | Group (al, cs, q) -> Printf.sprintf "γ[%s\n%s%s]"
            (String.concat ", " ((List.map string_of_agg al) @ (List.map string_of_col cs)))
            (make_indent depth) (f (depth + 1) q)
    in f 1

let print_col (c : col) = print_string (string_of_col c)
let print_pred (p : pred) = print_string (string_of_pred p)
let print_agg (a : agg) = print_string (string_of_agg a)
let print_query (q : query) = print_string (string_of_query q)
let print_query_nl (q : query) = print_query q; print_string "\n"
