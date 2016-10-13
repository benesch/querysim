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
%token AND
%token AS
%token BY
%token COMMA
%token DELETE
%token EQUALS
%token FROM
%token GROUP
%token INSERT
%token JOIN
%token LPAREN
%token ON
%token OR
%token ORDER
%token QMARK
%token RPAREN
%token SELECT
%token SEMICOLON
%token SET
%token UPDATE
%token WHERE

%%

sexp:
| ID { (Col $1, $1) }
| ID ID { (Col $1, $2) }
| ID AS ID { (Col $1, $3) }

sexp_list:
| sexp { [$1] }
| sexp COMMA sexp_list { $1 :: $3 }

wexp:
| ID { Col $1 }
| QMARK { Param }
| INT { Int $1 }

where:
| wexp EQUALS wexp { [Binop (Eq, $1, $3)] }

order:
| {}
| ORDER BY ID {}

subselect:
| ID { Ref_table $1 }
| LPAREN select RPAREN { Ref_select $2 }

from:
| FROM subselect { $2 }
| from JOIN subselect ON LPAREN wexp RPAREN {
    Ref_join { join_type=Inner_join; join_table=$3; join_conditions=$6 }
  }

select:
| SELECT sexp_list from WHERE where order {
    { output=$2; from=$3; wher=$5; group_by=[]; order_by=$6 }
  }

query:
| select { Select $1 }

query_list:
| query EOF { [$1] }
| query SEMICOLON query_list { $1 :: $3 }
