(* Some notes on the design of these data types:
 *
 *     1. All column names must be unique across tables. This is no loss
 *        of generality and simplifies column-equivalence checks because
 *        provenance doesn't matter.
 *     2. Only equijoins are permitted. This is probably no big deal to start.. How
 *        often do theta-joins happen anyway?
 *)

(* Col (name), Lit (name, value), Param ? *)
type col = Col of string | Lit of string * string | Param
type pred = Equal of col * col
type agg = Count | Sum of col | Min of col | Max of col

type query =
    | Table of col list
    | Select of pred list * query
    | Project of col list * query
    | Union of query * query
    | Equijoin of col list * query * query
    | Group of agg list * col list * query

let string_of_col = function
    | Col s -> s
    | Lit (n, v) -> Printf.sprintf "(%s→\"%s\")" n v
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
let print_cols (cs : col list) = print_string (string_of_cols cs)
let print_pred (p : pred) = print_string (string_of_pred p)
let print_agg (a : agg) = print_string (string_of_agg a)
let print_query (q : query) = print_string (string_of_query q)
let print_query_nl (q : query) = print_query q; print_string "\n"

let rec cols = function
    | Table cs -> cs
    | Select (p, q) -> cols q
    | Project (cs, q) -> cs
    | Union (q1, q2) -> cols q1 @ cols q2
    | Equijoin (p, q1, q2) -> cols q1 @ cols q2
    | Group (aggs, cs, q) -> cs

let col_compare c1 c2 = match (c1, c2) with
    | (Col a, Col b)
    | (Lit (a, _), Lit (b, _))
    | (Col a, Lit (b, _))
    | (Lit (a, _), Col b) -> compare a b
    | (Param, Param) -> 0
    | (_, Param) -> -1
    | (Param, _) -> 1

let cols_equal (c1s : col list) (c2s : col list) =
    let s1 = (List.sort col_compare c1s) in
    let s2 = (List.sort col_compare c2s) in
    if List.length s1 <> List.length s2 then true
    else List.for_all2 (fun c1 c2 -> 0 = col_compare c1 c2) s1 s2

(* let queries_equal (q1 : query) (q2: query) = match (q1, q2) with
    | (Table c1, Table c2) -> cols_equal c1 c2
    | (Select (p1, q1'), (p2, q2')) ->  *)

let valid_select_col (cs : col list) (c : col) =
    match c with
    | Col _ -> List.mem c cs
    | Lit _ | Param -> true

let valid_column (cs : col list) (c : col) =
    match c with
    | Col _ | Lit _ -> List.mem c cs
    | Param -> true

let rec valid_query = function
    | Table cs ->
        List.for_all (function Col _ -> true | Lit _ -> true | Param -> false) cs
    | Select (ps, q) ->
        let cs = cols q in
        List.for_all
            (fun (Equal (c1, c2)) -> valid_select_col cs c1 && valid_select_col cs c2)
            ps
    | Project (cs, q) ->
        let qcs = cols q in
        List.for_all (valid_select_col qcs) cs
    | Union (q1, q2) ->
        let q1cs = cols q1 in
        let q2cs = cols q2 in
        valid_query q1 && valid_query q2 && cols_equal q1cs q2cs
    | Equijoin (cs, q1, q2) ->
        let q1cs = cols q1 in
        let q2cs = cols q2 in
        List.for_all (fun c -> valid_column q1cs c && valid_column q2cs c) cs
    | Group (aggs, cs, q) ->
        let qcs = cols q in
        List.for_all (valid_column qcs) cs &&
        List.for_all (function Count -> true | Sum c | Min c | Max c -> List.mem c qcs) aggs
;;

let assert_valid (q : query) = assert (valid_query q) ;;
let assert_invalid (q : query) = assert (not (valid_query q)) ;;

assert_valid (Table [Col "a"; Col "b"; Lit ("c", "4")]) ;;
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
            let c1s = cols q1 in
            let c2s = cols q2 in
            let p1s = List.filter (checkp c1s) pushps in
            let p2s = List.filter (checkp c2s) pushps in
            Equijoin (cs, Select (p1s, q1), Select (p2s, q2)) in
        Select (stayps, innerq)
    | Project (cs, q) -> Project (cs, push_selects q)
    | Union (q1, q2) -> Union (push_selects q1, push_selects q2)
    | Equijoin (cs, q1, q2) -> Equijoin (cs, push_selects q1, push_selects q2)
    | Group (aggs, cs, q) -> Group (aggs, cs, push_selects q)

let rec push_groups = function
    | Table cs -> Table cs
    | Select (ps, q) -> Select (ps, push_groups q)
    | Project (cs, q) -> Project (cs, push_groups q)
    | Union (q1, q2) -> Union (push_groups q1, push_groups q2)
    | Equijoin (cs, q1, q2) -> Equijoin (cs, push_groups q1, push_groups q2)
    | Group (aggs, cs, q) ->
        let has_lit_one c cs = match c with
            | Col c -> List.exists (function Lit (n, "1") -> c = n | _ -> false) cs
            | Lit (n, v) -> v = "1"
            | Param -> failwith "unexpected param"
        in
        let qcs = cols q in
        let aggs = List.map (fun agg -> match agg with
            | Sum c -> if has_lit_one c qcs then Count else agg
            | _ as agg -> agg) aggs
        in
        match q with
            | Table _ | Project _ | Equijoin _ | Select _ | Group _ -> Group (aggs, cs, q)
            | Union (q1, q2) -> Union (Group (aggs, cs, q1), Group (aggs, cs, q2))

let rec prune_projs = function
    | Table cs -> Table cs
    | Select (ps, q) -> Select (ps, prune_projs q)
    | Project (cs, q) -> Project (cs, prune_projs q)
    | Union (q1, q2) -> Union (prune_projs q1, prune_projs q2)
    | Equijoin (cs, q1, q2) -> Equijoin (cs, prune_projs q1, prune_projs q2)
    | Group (aggs, cs, q) -> match q with
        | Table _ | Equijoin _ | Select _ | Group _ | Union _ -> Group (aggs, cs, q)
        | Project (cs', q') ->
            let gcs = (BatList.filter_map (function Sum c | Min c | Max c -> Some c | _ -> None) aggs) @ cs in
            Group (aggs, cs, Project (gcs, q'))

let rec normalize = function
    | Table cs -> Table cs
    | Select (ps, q) -> if ps = [] then normalize q else Select (ps, normalize q)
    | Union (q1, q2) -> Union (normalize q1, normalize q2)
    | Equijoin (cs, q1, q2) -> Equijoin (cs, normalize q1, normalize q2)
    | Project (cs, q) -> Project (cs, normalize q)
    | Group (aggs, cs, q) -> Group (aggs, cs, q)

let optimize (q : query) = normalize (prune_projs (push_groups (push_selects q)))
