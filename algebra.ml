open Printf

module Hashtbl = BatHashtbl

type name = string
type func = string

(* XXX: All literals are represented as strings, and coerced to other
 * data types as necessary. This matches Soup v2's behavior, but may
 * prove limiting. *)
type lit = string

(* For both sanity and interoperability with Soup v2, a column reference
 * is a pair of ints, with the first int identifying the subquery and
 * the second int identifying the element within that subquery's output
 * columns.
 *
 * With the exception of base tables, each query refers to one or more
 * subqueries. Selections and projections, for example, refer to exactly
 * one subquery; joins currently refer to two, a left subquery and a
 * right subquery. For selections and projections, the query index must
 * always be 0; for joins, 0 is the left table and 1 is the right table.
 * (Future work may allow joins to have more than two sub queries.) *)
type col = int * int

type agg = Count | Sum of col | Min of col | Max of col

type binop = Eq | Neq | And | Or | Gt | Lt | Gte | Lte

type exp =
  | Col of col
  | Lit of string
  | Param
  | Binop of binop * exp * exp
  | Call of func * exp list

type proj = { proj_exp : exp; proj_alias : name option }

type query =
  | Table of name list
  | Stored of name
  | Select of exp * query
  | Project of proj list * query
  | Union of query * query
  | Join of (col * col) list * query * query
  | Group of agg * col list * query

type stored_query =
  { sq_visible : bool; sq_query : query }

type database =
  { db_counter : int ref;
    db_viewtbl : (name, stored_query) Hashtbl.t;
    db_nametbl : (query, name) Hashtbl.t }

let new_database () =
  { db_counter = ref 0;
    db_viewtbl = Hashtbl.create 1;
    db_nametbl = Hashtbl.create 1 }

let add_query db name stored_query =
  assert (not (Hashtbl.mem db.db_viewtbl name));
  assert (not (Hashtbl.mem db.db_nametbl stored_query.sq_query));
  Hashtbl.add db.db_viewtbl name stored_query;
  Hashtbl.add db.db_nametbl stored_query.sq_query name

let add_external_query db name query =
  if Hashtbl.mem db.db_nametbl query then
    failwith "query already exists";
  if Hashtbl.mem db.db_viewtbl name then
    failwith "query with that name already exists";
  add_query db name { sq_visible = true; sq_query = query }

let add_table db name columns =
  add_external_query db name (Table columns)

let add_internal_query db query =
  match Hashtbl.find_option db.db_nametbl query with
  | None ->
      let name = sprintf "query-%d" (BatRef.post_incr db.db_counter) in
      Hashtbl.add db.db_viewtbl name { sq_visible = false; sq_query = query };
      Hashtbl.add db.db_nametbl query name;
      name
  | Some name ->
      (* It's not an error to add the same internal query more than once. This
       * happens quite frequently. *)
      name

let update_query db name query =
  let old_sq = Hashtbl.find db.db_viewtbl name in
  Hashtbl.replace db.db_viewtbl name { old_sq with sq_query = query };
  Hashtbl.remove db.db_nametbl old_sq.sq_query;
  Hashtbl.add db.db_nametbl query name

let database_with_table name columns =
  let db = new_database () in
  add_table db name columns;
  db

let database_lookup db name =
  (Hashtbl.find db.db_viewtbl name).sq_query

let rec map_query f = function
  | Stored name -> Stored name
  | Table names -> Table names
  | Select (pred, query) -> f (Select (pred, (map_query f query)))
  | Project (projs, query) -> f (Project (projs, (map_query f query)))
  | Group (agg, cols, query) -> f (Group (agg, cols, (map_query f query)))
  | Union (query1, query2) -> f (Union (map_query f query1, map_query f query2))
  | Join (cols, query1, query2) -> f (Join (cols, map_query f query1, map_query f query2))

let rec predecessors = function
  | Table _ -> []
  | Stored name -> [name]
  | Select (_, query)
  | Project (_, query)
  | Group (_, _, query) ->
      predecessors query
  | Union (query1, query2)
  | Join (_, query1, query2) ->
      (predecessors query1) @ (predecessors query2)

exception Cycle_found

let view_names db =
  Hashtbl.fold (fun k _ accu -> k :: accu) db.db_viewtbl []

let toposorted_view_names db =
  let rec toposort seen visited name =
    if List.mem name seen then raise Cycle_found;
    if List.mem name visited then visited
    else
      let seen' = name :: seen in
      let pred = predecessors (database_lookup db name) in
      let visited = List.fold_left (toposort seen') visited pred in
      name :: visited
  in
  List.rev @@ List.fold_left
    (fun visited name -> toposort [] visited name) [] (view_names db)

let split_database db =
  let split_query name =
    let query = database_lookup db name in
    update_query db name (map_query (fun q ->
      let name' = (add_internal_query db q) in
      if name' = name then q else Stored name') query) in
  (* XXX: OCaml hash tables don't allow modifications during iteration, so
   * it's important to make a copy first. *)
  List.iter split_query (view_names db)

let database_iter f db =
  let view_names = toposorted_view_names db in
  List.iter (fun name -> f name (database_lookup db name)) view_names

let database_map f db =
  let view_names = toposorted_view_names db in
  List.map (fun name -> f name (database_lookup db name)) view_names

let col_of_agg = function
  | Count -> None
  | Sum col | Min col | Max col -> Some col

let rec ncols (db : database) (query : query) = match query with
  | Table names -> List.length names
  | Stored name -> ncols db (database_lookup db name)
  | Select (_, query) -> ncols db query
  | Project (projs, query) -> List.length projs
  | Group (agg, cols, query) -> 1 + (List.length cols)
  | Union (query1, query2) ->
      let ncols1 = ncols db query1 in
      let ncols2 = ncols db query2 in
      assert (ncols1 = ncols2);
      ncols1
  | Join (cols, query1, query2) ->
      (ncols db query1) + (ncols db query2) - (List.length cols)

let rec col_names (db : database) (query : query) : name list = match query with
  | Table names -> names
  | Stored name -> col_names db (database_lookup db name)
  | Select (_, query) -> col_names db query
  | Project (projs, query) ->
      let names = col_names db query in
      let col_of_proj (proj : proj) = match proj with
        | {proj_alias = Some alias; proj_exp = _} -> alias
        | {proj_alias = None; proj_exp = Col (0, ti)} ->
            (List.nth names ti)
        | {proj_alias = None; proj_exp = Col (_, _)} ->
            failwith "invalid column"
        | _ -> failwith "no alias specified for non-column projection"
      in
      List.map col_of_proj projs
  | Union (query1, query2) ->
      (* XXX: Uses the left query's column names. *)
      col_names db query1
  | Join (cols, query1, query2) ->
      let mentioned_cols =
        List.flatten (List.map (fun (c1, c2) -> [c1; c2]) cols)
      in
      let left_col_names = col_names db query1 in
      let right_col_names =
        Util.filteri
          (fun i _ -> not (List.mem (1, i) mentioned_cols))
          (col_names db query2)
      in
      left_col_names @ right_col_names
  | Group (agg, cols, query) ->
      let col_names = col_names db query in
      let output_name = (string_of_agg [col_names] agg) in
      (Util.filteri (fun i _ -> List.mem (0, i) cols) col_names) @ [output_name]

and string_of_agg names agg =
  let lookup (i, j) = List.nth (List.nth names i) j in
  match agg with
  | Sum c -> sprintf "Sum(%s)" (lookup c)
  | Count -> "Count"
  | Min c -> sprintf "Min(%s)" (lookup c)
  | Max c -> sprintf "Max(%s)" (lookup c)

let string_of_col ?qualify names col =
  let (i, j) = col in
  let table = match (qualify, i) with
    | (None, _) -> ""
    | (Some _, 0) -> "l."
    | (Some _, 1) -> "r."
    | (Some _, _) -> failwith "unexpected number of columns"
  in
  sprintf "%s%d:%s" table j (List.nth (List.nth names i) j)

let string_of_cols names cols =
  String.concat ", " (List.map (string_of_col names) cols)

let string_of_binop = function
  | Eq -> "="
  | Neq -> "!="
  | And -> "AND"
  | Or -> "OR"
  | Gt -> ">"
  | Lt -> "<"
  | Gte -> ">="
  | Lte -> "<="

let rec string_of_exp ?(string_of_col=string_of_col) names = function
  | Col c -> string_of_col names c
  | Lit l -> "\"" ^ l ^ "\""
  | Param -> "?"
  | Binop (b, e1, e2) ->
      sprintf "(%s %s %s)"
      (string_of_exp ~string_of_col names e1) (string_of_binop b) (string_of_exp ~string_of_col names e2)
  | Call (func, es) ->
      sprintf "%s(%s)"
      func (String.concat ", " (List.map (string_of_exp ~string_of_col names) es))

let string_of_proj names = function
  | {proj_alias = Some a; proj_exp = e} ->
      sprintf "%s→%s" a (string_of_exp names e)
  | {proj_alias = None; proj_exp = e} -> string_of_exp names e

let string_of_projs names ps =
    String.concat ", " (List.map (string_of_proj names) ps)

let string_of_query (db : database) =
  let make_indent depth = String.make (depth * 4) ' ' in
  let rec f depth = function
    | Table names ->
        sprintf "𝓕[%s]" (String.concat ", " names)
    | Stored name ->
        sprintf "𝓢[%s]" name
    | Select (e, q) ->
        let names = [col_names db q] in
        sprintf "σ[%s\n%s%s]"
            (string_of_exp names e) (make_indent depth) (f (depth + 1) q)
    | Project (ps, q) ->
        let names = [col_names db q] in
        sprintf "π[%s  %s]" (string_of_projs names ps) (f depth q)
    | Union (q1, q2) ->
        sprintf "∪[\n%s%s\n%s%s]"
        (make_indent depth) (f (depth + 1) q1)
        (make_indent depth) (f (depth + 1) q2)
    | Join (cols, q1, q2) ->
        let names = [col_names db q1; col_names db q2] in
        sprintf "⋈[%s\n%s%s\n%s%s]"
        (String.concat ", " (List.map (fun (c1, c2) ->
          let c1 = (string_of_col ~qualify:() names c1) in
          let c2 = (string_of_col ~qualify:() names c2) in
          sprintf "%s=%s" c1 c2) cols))
        (make_indent depth) (f (depth + 1) q1)
        (make_indent depth) (f (depth + 1) q2)
    | Group (agg, cs, q) ->
        let names = [col_names db q] in
        sprintf "γ[%s  %s\n%s%s]"
        (String.concat ", " (List.map (string_of_col names) cs))
        (string_of_agg names agg)
        (make_indent depth) (f (depth + 1) q)
  in f 1

let json_of_query db name query =
  let snag_name query = match query with
    | Stored s -> `String s
    | _ -> failwith "eep! unsplit query encountered during json conversion" in
  (* XXX: Next bit is horrible. Whatever. It'll change anyway because
   * string representation of expressions would require annoying
   * parsing on the Soup end. *)
  let json_of_exp exp =
    `String (string_of_exp
      ~string_of_col:(fun ?qualify _ (i, j) -> string_of_int j)
      [] exp) in
  let json_of_string_list strings =
    `List (List.map (fun s -> `String s) strings) in
  let col_names' db query =
    json_of_string_list (col_names db query) in
  let json_of_join_cols cols =
    let max1, max2 = List.fold_left (fun (max1, max2) ((_, j1), (_, j2)) ->
      (max max1 j1, max max2 j2)) (0, 0) cols in
    let left = Array.make (max1 + 1) (`Int 0) in
    let right = Array.make (max2 + 1) (`Int 0) in
    List.iteri (fun i ((_, j1), (_, j2)) -> left.(j1) <- (`Int (i + 1)); right.(j2) <- (`Int (i + 1))) cols;
    `List [`List (Array.to_list left); `List (Array.to_list right)] in
  let agg_func = function
    | Count -> `String "COUNT"
    | Sum _ -> `String "SUM"
    | Min _ -> `String "MIN"
    | Max _ -> `String "MAX" in
  let agg_col = function
    | Count -> `Null
    | Sum c | Min c | Max c -> `Int (snd c) in
  match query with
    | Table names -> `Assoc
        [("name", `String name);
         ("type", `String "Base");
         ("outputs", json_of_string_list names)]
    | Stored s -> `Assoc
        [("name", `String name);
         ("type", `String "Alias");
         ("from", `List [`String s])]
    | Select (exp, query') -> `Assoc
        [("name", `String name);
         ("type", `String "Identity");
         ("from", `List [snag_name query']);
         ("outputs", col_names' db query);
         ("having", json_of_exp exp)]
    | Project (projs, query') -> `Assoc
        [("name", `String name);
         ("type", `String "Identity");
         ("from", `List [snag_name query']);
         ("outputs", col_names' db query)]
    | Join (cols, query1, query2) -> `Assoc
        [("name", `String name);
         ("type", `String "Join");
         ("from", `List [snag_name query1; snag_name query2]);
         ("on", json_of_join_cols cols);
         ("outputs", col_names' db query)]
    | Union (query1, query2) -> `Assoc
        [("name", `String name);
         ("type", `String "Union");
         ("from", `List [snag_name query1; snag_name query2]);
         ("outputs", col_names' db query)]
    | Group (agg, cols, query') -> `Assoc
        [("name", `String name);
         ("type", `String "Group");
         ("from", `List [snag_name query']);
         ("func", agg_func agg);
         ("over", agg_col agg);
         ("by", `List (List.map (fun (i, j) -> `Int j )cols));
         ("outputs", col_names' db query)]


let print_col db col = print_string (string_of_col db col)
let print_cols db cols = print_string (string_of_cols db cols)
let print_proj db proj = print_string (string_of_proj db proj)
let print_agg db agg = print_string (string_of_agg db agg)
let print_query db query = print_string (string_of_query db query)
let print_query_nl db query = print_query db query; print_string "\n"

let print_info db name query =
  printf "NAME:    %s\n%!" name;
  printf "COLUMNS: %s\n%!" (String.concat ", " (col_names db query));
  printf "PREDECESSORS: %s\n%!" (String.concat ", " (predecessors query));
  printf "QUERY:\n%s\n%!" (string_of_query db query)

let print_database db =
  database_iter
    (fun name query -> print_info db name query; printf "\n")
    db

let json_of_database db =
  `List (database_map (fun name query -> json_of_query db name query) db)

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
            | Union (q1, q2) -> Union (Group (aggs, cs, q1), Group (aggs, cs, q2)) *)

let push_selects db q = q
let push_groups db q = q

(* let rec prune_projs (db : database) = function
    | Table cols -> Table cols
    | Stored name -> prune_projs db (database_lookup db name)
    | Select (ps, q) -> Select (ps, prune_projs db q)
    | Project (cs, q) -> Project (cs, prune_projs db q)
    | Union (q1, q2) -> Union (prune_projs db q1, prune_projs db q2)
    | Join (cs, q1, q2) -> Join (cs, prune_projs db q1, prune_projs db q2)
    | Group (agg, cs, q) -> match q with
        | Project (cs', q') ->
            let gcs = match col_of_agg agg with
              | None -> cs
              | Some col -> col :: cs
            in
            Group (agg, cs, Project (gcs, q'))
        | _ -> Group (agg, cs, q)
 *)
let prune_projs db q = q

let rec normalize (db : database) = function
  | Stored s -> Stored s
  | Table cols -> Table cols
  | Select (e, q) -> Select (e, normalize db q)
  | Union (q1, q2) -> Union (normalize db q1, normalize db q2)
  | Join (cs, q1, q2) -> Join (cs, normalize db q1, normalize db q2)
  | Project (cs, q) -> Project (cs, normalize db q)
  | Group (aggs, cs, q) -> Group (aggs, cs, q)

let optimize db q = normalize db (prune_projs db (push_groups db (push_selects db q)))

let rec algebra_of_from db f =
  let rec inner f = match f with
    | (Sql.Ref_table t, alias) :: [] ->
        let subquery = Stored t in
        let name = match alias with None -> t | Some a -> a in
        let qual_names = List.map (fun cn -> (name, cn)) (col_names db subquery) in
        (qual_names, subquery)
    | (Sql.Ref_select s, Some alias) :: [] ->
        let subquery = algebra_of_select db s in
        let qual_names = List.map (fun cn -> (alias, cn)) (col_names db subquery) in
        (qual_names, subquery)
    | (Sql.Ref_select _, None) :: [] -> failwith "subselect missing name"
    | (Sql.Ref_join j, _) :: tl ->
      let (lnames, lsubquery) = inner [j.Sql.join_table] in
      let (rnames, rsubquery) = inner tl in
      let join_cols = match j.Sql.join_cond with
        | None -> failwith "natural joins not yet supported"
        | Some (Sql.Join_exp e) ->
            failwith "eep!" (* algebra_of_exp e *)
        | Some (Sql.Join_cols cols) ->
            let findi sql_col names =
              Util.findi (fun (tbl, col) -> sql_col.Sql.col = col) names
            in
            List.map (fun c -> ((0, findi c lnames), (1, findi c rnames))) cols
      in
      let mentioned_cols =
        List.flatten (List.map (fun (c1, c2) -> [c1; c2]) join_cols)
      in
      let qual_names = lnames @ Util.filteri
          (fun i _ -> not (List.mem (1, i) mentioned_cols))
          rnames
      in
      (qual_names, Join (join_cols, lsubquery, rsubquery))
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

and algebra_of_exp qual_names e : exp =
  let qn = qual_names in
  match e with
    | Sql.Param -> Param
    | Sql.Col {Sql.table = Some t; Sql.col = c} ->
        Col (0, Util.findi (fun (tbl, col) -> tbl = t && col = c) qn)
    | Sql.Col {Sql.table = None; Sql.col = c} ->
        Col (0, Util.findi (fun (tbl, col) -> col = c) qn)
    | Sql.Str s -> Lit s
    | Sql.Int i -> Lit (string_of_int i)
    | Sql.Binop (op, e1, e2) ->
        Binop (algebra_of_op op, algebra_of_exp qn e1, algebra_of_exp qn e2)
    | Sql.Call (func, es) ->
        Call (func, List.map (algebra_of_exp qn) es)
    | Sql.Is_null e ->
        Binop (Eq, algebra_of_exp qn e, Lit "")
    | Sql.Not (Sql.Is_null e) ->
        Binop (Neq, algebra_of_exp qn e, Lit "")
    | Sql.True -> Lit "true"
    | Sql.Null -> Lit "null"
    | _ -> failwith "unsupported exp"

and algebra_of_proj qual_names (exp, alias) =
  match exp with
  | Sql.Col {Sql.table = Some t; Sql.col = "*"} ->
      if alias = Some "*" then failwith "alias of *"
      else BatList.filteri_map (fun i (tbl, col) -> if tbl = t then Some {proj_exp = Col (0, i); proj_alias = None} else None) qual_names
  | Sql.Col {Sql.table = None; Sql.col = "*"} ->
      if alias = Some "*" then failwith "alias of *"
      else List.mapi (fun i _ -> {proj_exp = Col (0, i); proj_alias = None}) qual_names
  | _ -> [{proj_exp = (algebra_of_exp qual_names exp); proj_alias = alias}]


and algebra_of_select db s =
  let (qual_names, subquery) = algebra_of_from db s.Sql.from in
  let wrap_where inner = match s.Sql.wher with
    | None -> inner
    | Some e -> Select (algebra_of_exp qual_names e, inner)
  in
  let (aggs, outputs) = List.fold_right
    (fun (exp, alias) (aggs, outputs) ->
      let (aggs', exp') = extract_groups qual_names exp in
      (aggs' @ aggs), ((exp', alias) :: outputs))
    s.Sql.output
    ([], [])
  in
  let gcols = List.map (fun exp -> match algebra_of_exp qual_names exp with
    | Col c -> c | _ -> failwith "non-simple group by column") s.Sql.group_by in
  let qual_names =
    if aggs = [] then qual_names else
    List.map (fun (qi, ti) -> assert (qi = 0); (List.nth qual_names ti)) gcols
    @ (List.map (fun a -> ("(auto-gen)", agg_col_name qual_names a)) aggs) in
  let rec wrap_group inner = match aggs with
    | [] -> inner
    | agg :: [] -> Group (agg, gcols, inner)
    | _ -> failwith "eep! only one groupby supported" in
  let ps = List.flatten (List.map (algebra_of_proj qual_names) outputs) in
  Project (ps, wrap_group (wrap_where subquery))

and agg_col_name qual_names agg =
  string_of_agg [List.map (fun (tbl, col) -> col) qual_names] agg

and extract_groups qual_names exp =
  let qn = qual_names in
  match exp with
    | Sql.Param | Sql.Col _ | Sql.Str _ | Sql.Int _
    | Sql.True | Sql.False | Sql.Null ->
        ([], exp)
    | Sql.Is_null e ->
        let (g, e') = extract_groups qn e in
        (g, Sql.Is_null e')
    | Sql.Not e ->
        let (g, e') = extract_groups qn e in
        (g, Sql.Not e')
    | Sql.Binop (op, e1, e2) ->
        let (g1, e1') = extract_groups qn e1 in
        let (g2, e2') = extract_groups qn e2 in
        (g1 @ g2, Sql.Binop (op, e1', e2'))
    | Sql.Call (func, es) ->
        if not (List.for_all (fun (g, _) -> g = []) (List.map (extract_groups qn) es))
        then failwith "nested functions";
        let get_col () = match (algebra_of_exp qn (List.hd es)) with
          | Col c -> c
          | _ -> failwith "aggregation over non-simple expression" in
        let agg = match String.lowercase_ascii func with
          | "count" -> Some Count
          | "sum" -> Some (Sum (get_col ()))
          | "min" -> Some (Min (get_col ()))
          | "max" -> Some (Max (get_col ()))
          | _ -> None in
        begin match agg with
          | None -> ([], Sql.Call(func, es))
          | Some a -> ([a], Sql.Col {Sql.table = None; Sql.col = agg_col_name qn a})
        end
    | _ -> failwith "eep!"

let algebra_of_sql db sql = match sql with
  | Sql.Select s -> algebra_of_select db s
  | _ -> failwith "unsupported query type"

let add_external_sql db name sql_string =
  add_external_query db name (algebra_of_sql db (Sql.parse_string sql_string))
