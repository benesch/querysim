type col = string
type func = string

type agg = Count | Sum of col | Min of col | Max of col

type binop = Eq | Neq | And | Or | Gt | Lt | Gte | Lte

type exp =
  | Col of col | Lit of string | Param
  | Binop of binop * exp * exp
  | Call of func * exp list

type proj = { pexp : exp; alias : string option }

type database = (string, string list) Hashtbl.t

type query =
    | Table of string
    | Select of exp * query
    | Project of proj list * query
    | Union of query * query
    | Join of exp * query * query
    | Group of agg list * col list * query

let new_database () : database = Hashtbl.create 1

let add_table db name cs = Hashtbl.add db name cs

let db_with_table name cs =
  let db = new_database () in
  add_table db name cs;
  db

let col_of_proj = function
  | {pexp = _; alias = Some a} -> a
  | {pexp = Col c; alias = None} -> c
  | _ -> failwith "no alias specified for non-column projection"

let rec cols (db : database) = function
  | Table t -> Hashtbl.find db t
  | Select (_, q) -> cols db q
  | Project (ps, q) -> List.map col_of_proj ps
  | Union (q1, q2) -> cols db q1 @ cols db q2
  | Join (_, q1, q2) -> cols db q1 @ cols db q2
  | Group (aggs, cs, q) -> cs

let string_of_cols (cs : col list) = String.concat ", " cs

let string_of_binop = function
  | Eq -> "="
  | Neq -> "!="
  | And -> "AND"
  | Or -> "OR"
  | Gt -> ">"
  | Lt -> "<"
  | Gte -> ">="
  | Lte -> "<="

let rec string_of_exp = function
  | Col c -> c
  | Lit l -> "\"" ^ l ^ "\""
  | Param -> "?"
  | Binop (b, e1, e2) ->
      Printf.sprintf "(%s %s %s)"
      (string_of_exp e1) (string_of_binop b) (string_of_exp e2)
  | Call (func, es) ->
      Printf.sprintf "%s(%s)"
      func (String.concat ", " (List.map string_of_exp es))

let string_of_proj = function
  | {pexp = e; alias = Some a} -> Printf.sprintf "(%s→%s)" a (string_of_exp e)
  | {pexp = e; alias = None} -> string_of_exp e

let string_of_projs ps = String.concat ", " (List.map string_of_proj ps)

let string_of_agg = function
    | Sum c -> Printf.sprintf "Sum(%s)" c
    | Count -> "Count"
    | Min c -> Printf.sprintf "Min(%s)" c
    | Max c -> Printf.sprintf "Max(%s)" c

let string_of_query (db : database) =
    let make_indent depth = String.make (depth * 4) ' ' in
    let rec f depth = function
        | Table tn as t ->
            Printf.sprintf "𝓕[%s: %s]" tn (string_of_cols (cols db t))
        | Select (e, q) ->
            Printf.sprintf "σ[%s\n%s%s]"
                (string_of_exp e) (make_indent depth) (f (depth + 1) q)
        | Project (ps, q) ->
            Printf.sprintf "π[%s  %s]" (string_of_projs ps) (f depth q)
        | Union (q1, q2) ->
            Printf.sprintf "∪[\n%s%s\n%s%s]"
            (make_indent depth) (f (depth + 1) q1)
            (make_indent depth) (f (depth + 1) q2)
        | Join (e, q1, q2) ->
            Printf.sprintf "⋈[%s\n%s%s\n%s%s]"
            (string_of_exp e)
            (make_indent depth) (f (depth + 1) q1)
            (make_indent depth) (f (depth + 1) q2)
        | Group (aggs, cs, q) -> Printf.sprintf "γ[%s\n%s%s]"
            (String.concat ", " ((List.map string_of_agg aggs) @ cs))
            (make_indent depth) (f (depth + 1) q)
    in f 1

let print_col (c : col) = print_string c
let print_cols (cs : col list) = print_string (string_of_cols cs)
let print_proj (p : proj) = print_string (string_of_proj p)
let print_agg (a : agg) = print_string (string_of_agg a)
let print_query (db : database) (q : query) = print_string (string_of_query db q)
let print_query_nl (db : database) (q : query) = print_query db q; print_string "\n"

(* XXX: This is hilariously far from perfect, but it'll do for simple
   cases. *)
let rec exps_equal (e1 : exp) (e2 : exp) = match e1, e2 with
  | Col _, Col _ | Param, Param | Lit _, Lit _ -> e1 = e2
  | Binop (Eq, e11, e12), Binop (Eq, e21, e22)
  | Binop (And, e11, e12), Binop (And, e21, e22)
  | Binop (Or, e11, e12), Binop (Or, e21, e22) ->
      (exps_equal e11 e21 && exps_equal e12 e22) ||
      (exps_equal e11 e22 && exps_equal e12 e21)
  | Binop (Gt, e11, e12), Binop (Gt, e21, e22)
  | Binop (Lt, e11, e12), Binop (Lt, e21, e22)
  | Binop (Gte, e11, e12), Binop (Gte, e21, e22)
  | Binop (Lte, e11, e12), Binop (Lte, e21, e22) ->
      (exps_equal e11 e21 && exps_equal e12 e22)
  | _ -> false

let cols_equal (c1s : col list) (c2s : col list) =
    let s1 = (List.sort compare c1s) in
    let s2 = (List.sort compare c2s) in
    if List.length s1 <> List.length s2 then false
    else List.for_all2 (fun c1 c2 -> compare c1 c2 = 0) s1 s2

(* let queries_equal (q1 : query) (q2: query) = match (q1, q2) with
    | (Table c1, Table c2) -> cols_equal c1 c2
    | (Select (p1, q1'), (p2, q2')) ->  *)

let rec valid_select_exp (cs : col list) (e : exp) = match e with
  | Lit _ | Param -> true
  | Col c -> List.mem c cs
  | Binop (b, e1, e2) -> valid_select_exp cs e1 && valid_select_exp cs e2
  | Call (func, es) -> List.for_all (valid_select_exp cs) es

let rec valid_join_exp (cs : col list) (e : exp) = match e with
  | Param -> false
  | Lit _ -> true
  | Col c -> List.mem c cs
  | Binop (b, e1, e2) -> valid_join_exp cs e1 && valid_join_exp cs e2
  | Call (func, es) -> List.for_all (valid_join_exp cs) es

let valid_proj (cs : col list) (p : proj) =
  valid_join_exp cs p.pexp

let rec valid_query (db : database) = function
  | Table t -> Hashtbl.mem db t
  | Select (e, q) ->
      let cs = cols db q in
      valid_select_exp cs e && valid_query db q
  | Project (ps, q) ->
      let cs = cols db q in
      List.for_all (valid_proj cs) ps && valid_query db q
  | Union (q1, q2) ->
      let q1cs = cols db q1 in
      let q2cs = cols db q2 in
      valid_query db q1 && valid_query db q2 && cols_equal q1cs q2cs
  | Join (e, q1, q2) ->
      let q1cs = cols db q1 in
      let q2cs = cols db q2 in
      valid_join_exp (q1cs @ q2cs) e && valid_query db q1 && valid_query db q2
  | Group (aggs, cs, q) ->
      let qcs = cols db q in
      List.for_all (fun c -> List.mem c qcs) cs &&
      List.for_all (function Count -> true | Sum c | Min c | Max c -> List.mem c qcs) aggs &&
      valid_query db q

let assert_valid (db : database) (q : query) = assert (valid_query db q)
let assert_invalid (db : database) (q : query) = assert (not (valid_query db q))

let _ = assert_valid
    (db_with_table "tb" ["a"; "b"])
    (Table "tb")

let _ = assert_invalid
    (db_with_table "badtb" [])
    (Table "goodtb")

let _ = assert_valid
    (db_with_table "tb" ["a"; "b"])
    (Select (Binop (Eq, Col "a", Col "b"), Table "tb"))

let _ = assert_invalid
    (db_with_table "tb" ["a"; "b"])
    (Select (Binop (Eq, Col "a", Col "c"), Table "tb"))

let _ = assert_valid
    (db_with_table "tb" ["a"; "b"; "c"])
    (Project (
      [{pexp = Col "c"; alias = None}; {pexp = Col "b"; alias = None}],
      Table "tb"))

let _ = assert_invalid
    (db_with_table "tb" ["a"; "b"; "c"])
    (Project (
      [{pexp = Col "c"; alias = None}; {pexp = Col "d"; alias = None}],
      Table "tb"))

let _ = assert_invalid
    (let db = new_database () in
        add_table db "a" ["a"];
        add_table db "b" ["b"];
        db)
    (Union (Table "a", Table "b"))

let _ = assert_valid
    (db_with_table "tb" ["a"])
    (Group ([Sum "a"], [], Table "tb"))

let _ = assert_invalid
    (db_with_table "tb" ["a"])
    (Group ([Sum "b"], [], Table "tb"))

let rec has_param = function
  | Param -> true
  | Lit _ -> false
  | Col _ -> false
  | Binop (b, e1, e2) -> has_param e1 || has_param e2
  | Call (func, es) -> List.exists has_param es

(* let rec push_selects (db : database) = function
    | Table t -> Table t
    | Select (ps, q) ->
        let (stayps, pushps) = List.partition (has_param) ps in
        let innerq = match q with
        | Table _ | Group _ | Project _ -> Select (ps, q)
        | Select (ps', q') ->
            let (stayps', pushps') = List.partition (has_param) ps' in
            Select (stayps @ stayps', push_selects db (Select (pushps @ pushps', q')))
        | Union (q1, q2) -> Union (Select (pushps, q1), Select (pushps, q2))
        | Equijoin (cs, q1, q2) ->
            let checkc c cs = match c with
                | Col _ -> List.mem c cs
                | Lit _ -> true
                | Param -> failwith "unexpected param"
            in
            let checkp cs (Eq (c1, c2)) = checkc c1 cs && checkc c2 cs in
            let c1s = cols db q1 in
            let c2s = cols db q2 in
            let p1s = List.filter (checkp c1s) pushps in
            let p2s = List.filter (checkp c2s) pushps in
            Equijoin (cs, Select (p1s, q1), Select (p2s, q2)) in
        Select (stayps, innerq)
    | Project (cs, q) -> Project (cs, push_selects db q)
    | Union (q1, q2) -> Union (push_selects db q1, push_selects db q2)
    | Equijoin (cs, q1, q2) -> Equijoin (cs, push_selects db q1, push_selects db q2)
    | Group (aggs, cs, q) -> Group (aggs, cs, push_selects db q)

let rec push_groups (db : database) = function
    | Table t -> Table t
    | Select (ps, q) -> Select (ps, push_groups db q)
    | Project (cs, q) -> Project (cs, push_groups db q)
    | Union (q1, q2) -> Union (push_groups db q1, push_groups db q2)
    | Equijoin (cs, q1, q2) -> Equijoin (cs, push_groups db q1, push_groups db q2)
    | Group (aggs, cs, q) ->
        let has_lit_one c cs = match c with
            | Col c -> List.exists (function Lit (n, "1") -> c = n | _ -> false) cs
            | Lit (n, v) -> v = "1"
            | Param -> failwith "unexpected param"
        in
        let qcs = cols db q in
        let aggs = List.map (fun agg -> match agg with
            | Sum c -> if has_lit_one c qcs then Count else agg
            | _ as agg -> agg) aggs
        in
        match q with
            | Table _ | Project _ | Equijoin _ | Select _ | Group _ -> Group (aggs, cs, q)
            | Union (q1, q2) -> Union (Group (aggs, cs, q1), Group (aggs, cs, q2))

let rec prune_projs (db : database) = function
    | Table t -> Table t
    | Select (ps, q) -> Select (ps, prune_projs db q)
    | Project (cs, q) -> Project (cs, prune_projs db q)
    | Union (q1, q2) -> Union (prune_projs db q1, prune_projs db q2)
    | Equijoin (cs, q1, q2) -> Equijoin (cs, prune_projs db q1, prune_projs db q2)
    | Group (aggs, cs, q) -> match q with
        | Table _ | Equijoin _ | Select _ | Group _ | Union _ -> Group (aggs, cs, q)
        | Project (cs', q') ->
            let gcs = (BatList.filter_map (function Sum c | Min c | Max c -> Some c | _ -> None) aggs) @ cs in
            Group (aggs, cs, Project (gcs, q')) *)

let rec normalize (db : database) = function
    | Table t -> Table t
    | Select (e, q) -> Select (e, normalize db q)
    | Union (q1, q2) -> Union (normalize db q1, normalize db q2)
    | Join (cs, q1, q2) -> Join (cs, normalize db q1, normalize db q2)
    | Project (cs, q) -> Project (cs, normalize db q)
    | Group (aggs, cs, q) -> Group (aggs, cs, q)

let optimize db q = normalize db q (* (prune_projs db (push_groups db (push_selects db q))) *)

(* XXX: aliases not handled *)
let rec algebra_of_from f =
  let rec inner f =
    match f with
      | (Sql.Ref_table t, _) :: [] -> Table t
      | (Sql.Ref_select s, _) :: [] -> algebra_of_select s
      | (Sql.Ref_join j, _) :: tl ->
        let exp = match j.Sql.join_cond with
          | None -> failwith "natural joins not yet supported"
          | Some (Sql.Join_exp e) -> algebra_of_exp e
          | Some (Sql.Join_cols cs) ->
              List.fold_left (fun memo c -> Binop (And, Col c.Sql.col, memo)) (Lit "true") cs
        in
        Join (exp, inner [j.Sql.join_table], inner tl)
      | _ -> failwith "from tables out of order"
  in
  inner (List.rev f)

and algebra_of_op o = match o with
  | Sql.Eq -> Eq
  | Sql.Neq -> Neq
  | Sql.And -> And
  | Sql.Or -> Or
  | Sql.Gt -> Gt | Sql.Lt -> Lt | Sql.Gte -> Gte | Sql.Lte -> Lte
  | Sql.In -> Eq (* XXX *)
  | Sql.Like -> Eq (* XXX *)
  | _ -> failwith "unsupported op"

and algebra_of_exp e = match e with
  | Sql.Param -> Param
  | Sql.Col {Sql.table = _; Sql.col = c} -> Col c
  | Sql.Str s -> Lit s
  | Sql.Int i -> Lit (string_of_int i)
  | Sql.Binop (op, e1, e2) ->
      Binop (algebra_of_op op, algebra_of_exp e1, algebra_of_exp e2)
  | Sql.Call (func, es) ->
      Call (func, List.map algebra_of_exp es)
  | Sql.Is_null e ->
      Binop (Eq, algebra_of_exp e, Lit "")
  | Sql.Not (Sql.Is_null e) ->
      Binop (Neq, algebra_of_exp e, Lit "")
  | Sql.True -> Lit "true"
  | Sql.Null -> Lit "null"
  | _ -> failwith "unsupported exp"

and algebra_of_select s =
  let wrap_where inner = match s.Sql.wher with
    | None -> inner
    | Some e -> Select (algebra_of_exp e, inner)
  in
  let ps =
    List.map (fun (e, a) -> {pexp = (algebra_of_exp e); alias = a}) s.Sql.output
  in
  Project (ps, wrap_where (algebra_of_from s.Sql.from))

and algebra_of_sql (sql : Sql.query) = match sql with
  | Sql.Select s -> algebra_of_select s
  | _ -> failwith "unsupported query type"
