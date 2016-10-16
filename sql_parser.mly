%{
open Sql
%}

%start query
%start query_list

%type <Sql.query> query
%type <Sql.query list> query_list

%token EOF
%token <float> FLOAT
%token <int> INT
%token <string> ID
%token <string> STRING
%token AMPERSAND
%token AND
%token AS
%token ASC
%token ASTERISK
%token BY
%token COMMA
%token DELETE
%token DESC
%token DISTINCT
%token DOT
%token EQ
%token FALSE
%token FROM
%token GROUP
%token GROUP_CONCAT
%token GT
%token GTE
%token INSERT
%token IS
%token IN
%token JOIN
%token LEFT
%token LIKE
%token LIMIT
%token LPAREN
%token LT
%token LTE
%token MINUS
%token NEQ
%token NOT
%token NULL
%token ON
%token OR
%token ORDER
%token PLUS
%token QMARK
%token RPAREN
%token SELECT
%token SEMICOLON
%token SEPARATOR
%token SET
%token SLASH
%token TRUE
%token UPDATE
%token USING
%token WHERE

%left OR
%left AND
%left NOT
%left EQ NEQ GT GTE LT LTE LIKE IN IS
%left PLUS MINUS
%left AMPERSAND
%left SLASH

%%

alias:
  | ID { Some $1 }
  | AS ID { Some $2 }

alias_opt:
  | { None }
  | alias { $1 }

exp:
  | LPAREN exp RPAREN { $2 }
  | LPAREN select RPAREN { Subquery $2 }
  | exp AND exp { Binop (And, $1, $3) }
  | exp OR exp { Binop (Or, $1, $3) }
  | exp EQ exp { Binop (Eq, $1, $3) }
  | exp NEQ exp { Binop (Neq, $1, $3) }
  | exp LT exp { Binop (Lt, $1, $3) }
  | exp LTE exp { Binop (Lte, $1, $3) }
  | exp GT exp { Binop (Gt, $1, $3) }
  | exp GTE exp { Binop (Gte, $1, $3) }
  | exp LIKE exp { Binop (Like, $1, $3) }
  | exp IN exp { Binop (In, $1, $3) }
  | exp PLUS exp { Binop (Add, $1, $3) }
  | exp MINUS exp { Binop (Sub, $1, $3) }
  | exp SLASH exp { Binop (Div, $1, $3) }
  | exp AMPERSAND exp { Binop (And, $1, $3) }
  | exp IS NULL { Is_null $1 }
  | exp IS NOT NULL { Not (Is_null $1) }
  | NOT exp { Not $2 }
  | ID LPAREN arg_list RPAREN { Call ($1, $3) }
  | col { Col $1 }
  | literal { $1 }
  | QMARK { Param }
  | GROUP_CONCAT LPAREN distinct_opt arg_list order_by separator_opt RPAREN {
      Call ("group_concat", $4)
    }

where:
  | { None }
  | WHERE exp { Some $2 }

order:
  | { Asc }
  | ASC { Asc }
  | DESC { Desc }

order_list:
  | { [] }
  | exp order { [($1, $2)] }
  | exp order COMMA order_list { ($1, $2) :: $4 }

order_by:
  | { [] }
  | ORDER BY order_list { $3 }

group_by:
  | { [] }
  | GROUP BY arg_list { $3 }

limit:
  | { None }
  | LIMIT INT { Some $2 }

table_primary:
  | ID alias_opt { (Ref_table $1, $2) }
  | LPAREN select RPAREN alias { (Ref_select $2, $4) }

join_type:
  | { Inner_join }
  | LEFT { Left_join }

col:
  | ID { { table=None; col=$1 } }
  | ID DOT ID { { table=Some $1; col=$3 } }

col_list:
  | col { [$1] }
  | col COMMA col_list { $1 :: $3 }

join_cond:
  | { None }
  | ON exp { Some (Join_exp $2) }
  | USING LPAREN col_list RPAREN { Some (Join_cols $3) }

joined_table:
  | table_ref join_type JOIN table_primary join_cond {
      $1 @ [(Ref_join { join_type=$2; join_table=$4; join_cond=$5 }, None)]
    }

table_ref:
  | table_primary { [$1] }
  | joined_table { $1 }

table_refs:
  | table_ref { $1 }
  | table_ref COMMA table_refs { $1 @ $3 }

arg_list:
  | { [] }
  | exp { [$1] }
  | exp COMMA arg_list { $1 :: $3 }

literal:
  | INT { Int $1 }
  | STRING { Str $1 }
  | TRUE { True }
  | FALSE { False }
  | NULL { Null }

separator_opt:
  | {}
  | SEPARATOR STRING {}
  | SEPARATOR QMARK {}

derived_col:
  | exp alias_opt { ($1, $2) }

select_list:
  | derived_col { [$1] }
  | derived_col COMMA select_list { $1 :: $3 }

distinct_opt:
  | { false }
  | DISTINCT { true }

from:
  | { [(Ref_table "Dual", None)] }
  | FROM table_refs { $2 }

select:
  | SELECT distinct_opt select_list from where group_by order_by limit {
      { distinct=$2; output=$3; from=$4; wher=$5; group_by=$6; order_by=$7; limit=$8 }
    }

query:
  | select { Select $1 }

query_list:
  | query EOF { [$1] }
  | query SEMICOLON query_list { $1 :: $3 }
