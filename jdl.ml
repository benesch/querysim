open Algebra
open Batteries

let subquery_name = function
  | Stored s -> `String s
  | _ -> failwith "jdl: unsplit query encountered during jdl conversion"

let jdl_enum variant fields =
  `Assoc [(variant, `Assoc fields)]

let jdl_of_lit = function
  | Str s -> `Assoc [("Text", `String s)]
  | Int i -> `Assoc [("Number", `Int i)]

let jdl_of_col (qi, ti) =
  assert (qi = 0);
  `Int ti

let jdl_of_exp exp =
  let rec f = function
    | Binop (And, e1, e2) ->
        f e1 @ f e2
    | Binop (Eq, Col c, Lit l)
    | Binop (Eq, Lit l, Col c) ->
        let val_ = `Assoc [("Const", jdl_of_lit l)] in
        let cmp = `Assoc [("Equal", val_)] in
        [`Assoc [("column", jdl_of_col c); ("cmp", cmp)]]
    | Binop (Eq, Col c1, Col c2) ->
        let val_ = `Assoc [("Column", jdl_of_col c2)] in
        let cmp = `Assoc [("Equal", val_)] in
        [`Assoc [("column", jdl_of_col c1); ("cmp", cmp)]]
    | _ -> failwith "jdl: unsupported exp" in
  `List (f exp)

let jdl_of_strings strings =
  `List (List.map (fun s -> `String s) strings)

let jdl_col_names db query =
  jdl_of_strings (col_names db query)

let jdl_of_projs projs =
  let extract_col p = match p.proj_exp with
    | Col (ti, ci) -> jdl_of_col (ti, ci)
    | _ -> failwith "jdl: non-column projection encountered"
  in
  `List (List.map extract_col projs)

let jdl_of_join_cols cols =
  let max1, max2 = List.fold_left
    (fun (max1, max2) ((_, j1), (_, j2)) -> (max max1 j1, max max2 j2))
    (0, 0) cols in
  let left = Array.make (max1 + 1) (`Int 0) in
  let right = Array.make (max2 + 1) (`Int 0) in
  List.iteri
    (fun i ((_, j1), (_, j2)) ->
      left.(j1) <- (`Int (i + 1));
      right.(j2) <- (`Int (i + 1)))
    cols;
  `List [`List (Array.to_list left); `List (Array.to_list right)]

let jdl_of_join_emit emit =
  `List (List.map (fun (ti, ci) -> `List [`Int ti; `Int ci]) emit)

let join_col_order db (cols, query1, query2) =
  let mentioned_cols =
    List.flatten (List.map (fun (c1, c2) -> [c1; c2]) cols) in
  let lnames = col_names db query1 in
  let rnames = col_names db query2 in
  (* We want all the left columns... *)
  let left = List.mapi (fun i _ -> (0, i)) lnames in
  (* ...and any right column that wasn't joined with a left column. *)
  let right = BatList.filteri_map
    (fun i _ ->
      if (List.mem (1, i) mentioned_cols) then None
      else Some ((1, i)))
    rnames in
  left @ right

let simplify_join db cols query1 query2 =
  let rec f query =
    let prior = match query with
      | Stored s -> database_lookup db s
      | _ -> failwith "jdl: unsplit query encountered" in
    match prior with
      | Project (ps, q) when Algebra.simple_project ps ->
          let (map, q') = f q in
          let map' = List.map (fun c -> map.(c)) (Algebra.proj_columns ps) in
          (BatArray.of_list map', q')
      | _ -> (BatArray.of_enum (0 --^ (ncols db query)), query) in
  let emit = join_col_order db (cols, query1, query2) in
  let (map1, query1) = f query1 in
  let (map2, query2) = f query2 in
  let map_col = function
    | (0, i) -> (0, map1.(i))
    | (1, i) -> (1, map2.(i))
    | _ -> failwith "unreachable" in
  let emit = List.map map_col emit in
  let cols = List.map (fun (l, r) -> (map_col l, map_col r)) cols in
  (emit, cols, query1, query2)

let jdl_of_query db name query =
  match query with
  | Table names ->
      jdl_enum "Base"
        [("name", `String name);
         ("outputs", jdl_of_strings names)]
  | Stored s ->
      jdl_enum "Alias"
        [("name", `String name);
         ("from", `String s)]
  | Select (exp, query') ->
      jdl_enum "Identity"
        [("name", `String name);
         ("from", subquery_name query');
         ("outputs", jdl_col_names db query);
         ("having", jdl_of_exp exp)]
  | Project (projs, query') ->
      jdl_enum "Permute"
        [("name", `String name);
         ("from", subquery_name query');
         ("emit", jdl_of_projs projs);
         ("outputs", jdl_col_names db query)]
  | Join (cols, query1, query2) ->
      let (emit, cols, query1, query2) = simplify_join db cols query1 query2 in
      jdl_enum "Join"
        [("name", `String name);
         ("from", `List [subquery_name query1; subquery_name query2]);
         ("emit", jdl_of_join_emit emit);
         ("on", jdl_of_join_cols cols);
         ("outputs", jdl_col_names db query)]
  | Union (query1, query2) ->
      jdl_enum "Union"
        [("name", `String name);
         ("from", `List [subquery_name query1; subquery_name query2]);
         ("outputs", jdl_col_names db query)]
  | Group (agg, cols, query') ->
      let agg_func = match agg with
        | Count -> `String "COUNT"
        | Sum _ -> `String "SUM"
        | Min _ -> `String "MIN"
        | Max _ -> `String "MAX" in
      let agg_col = match agg with
        | Count -> `Null
        | Sum c | Min c | Max c -> jdl_of_col c in
      jdl_enum "Group"
        [("name", `String name);
         ("from", subquery_name query');
         ("func", agg_func);
         ("over", agg_col);
         ("by", `List (List.map jdl_of_col cols));
         ("outputs", jdl_col_names db query)]

let jdl_of_database db =
  `List (database_map (fun name query -> jdl_of_query db name query) db)
