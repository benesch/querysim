type table = string [@@deriving show]
type alias = string [@@deriving show]
type col = string [@@deriving show]

type binop =
  | Add | Sub | Mul | Div
  | Eq | Neq | Lt | Lte | Gt | Gte
  | And | Or | BAnd
  [@@deriving show]

type join_type =
  | Inner_join | Left_join | Right_join | Full_join
  [@@deriving show]

type exp =
  | Param
  | Col of col
  | Str of string
  | Int of int
  | Binop of binop * exp * exp
  | Not of exp
  | Subquery of select
  [@@deriving show]

and select =
  { output : (exp * alias) list;
    from : (table_ref * alias) list;
    wher : exp list;
    group_by : exp list;
    order_by : exp list;
  }
  [@@deriving show]

and table_ref =
  | Ref_select of select
  | Ref_join of join
  | Ref_table of table
  [@@deriving show]

and join =
  { join_type : join_type;
    join_table : table_ref;
    join_conditions : exp;
  }
  [@@deriving show]

type query =
  | Select of select
  | Insert
  | Update
  | Alter
  [@@deriving show]
