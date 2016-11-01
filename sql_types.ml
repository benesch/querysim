type table = string [@@deriving show]
type alias = string [@@deriving show]
type col = { table : table option; col : string } [@@deriving show]
type func = string [@@deriving show]

type binop =
  | Add | Sub | Mul | Div
  | Eq | Neq | Lt | Lte | Gt | Gte | Like | In
  | And | Or | BAnd
  [@@deriving show]

type join_type =
  | Inner_join | Left_join
  [@@deriving show]

type order =
  | Asc | Desc
  [@@deriving show]

type exp =
  | Param
  | True
  | False
  | Null
  | Col of col
  | Str of string
  | Int of int
  | Binop of binop * exp * exp
  | Not of exp
  | Is_null of exp
  | Subquery of select
  | Call of func * exp list
  [@@deriving show]

and select =
  { distinct: bool;
    output : (exp * alias option) list;
    from : (table_ref * alias option) list;
    wher : exp option;
    group_by : exp list;
    order_by : (exp * order) list;
    limit : int option;
  }
  [@@deriving show]

and table_ref =
  | Ref_select of select
  | Ref_join of join
  | Ref_table of table
  [@@deriving show]

and join_cond =
  | Join_cols of col list
  | Join_exp of exp

and join =
  { join_type : join_type;
    join_table : table_ref * alias option;
    join_cond : join_cond option;
  }
  [@@deriving show]

type query =
  | Select of select
  | Insert
  | Update
  | Alter
  [@@deriving show]
