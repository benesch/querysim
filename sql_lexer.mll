{
open Lexing
open Sql_parser

let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_lnum = pos.pos_lnum + 1;
               pos_bol = pos.pos_cnum;
    }

let keywords = Hashtbl.create 32
let _ = List.iter
  (fun (kw, tok) -> Hashtbl.add keywords kw tok)
  [ "ASC", ASC
  ; "AND", AND
  ; "AS", AS
  ; "BY", BY
  ; "DELETE", DELETE
  ; "DESC", DESC
  ; "DISTINCT", DISTINCT
  ; "FALSE", FALSE
  ; "FROM", FROM
  ; "GROUP", GROUP
  ; "GROUP_CONCAT", GROUP_CONCAT
  ; "INSERT", INSERT
  ; "IN", IN
  ; "IS", IS
  ; "JOIN", JOIN
  ; "LEFT", LEFT
  ; "LIKE", LIKE
  ; "LIMIT", LIMIT
  ; "NULL", NULL
  ; "NOT", NOT
  ; "OR", OR
  ; "ON", ON
  ; "ORDER", ORDER
  ; "SELECT", SELECT
  ; "SEPARATOR", SEPARATOR
  ; "SET", SET
  ; "TRUE", TRUE
  ; "UPDATE", UPDATE
  ; "USING", USING
  ; "WHERE", WHERE
  ]
}

let whitespace = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let id = '*' | ['`']? ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']* ['`']?
let int = '-'? ['0'-'9']+
let strchr =  '\\' _ | "''" | [^ '\'' '\n']

rule lex = parse
| whitespace { lex lexbuf }
| newline    { next_line lexbuf; lex lexbuf }
| int        { INT (int_of_string (Lexing.lexeme lexbuf)) }
| '.'        { DOT }
| ','        { COMMA }
| '?'        { QMARK }
| '('        { LPAREN }
| ')'        { RPAREN }
| '>'        { GT }
| ">="       { GTE }
| '<'        { LT }
| "<="       { LTE }
| '='        { EQ }
| "!="       { NEQ }
| '+'        { PLUS }
| '-'        { MINUS }
| '/'        { SLASH }
| '&'        { AMPERSAND }
| id as id   { try Hashtbl.find keywords (String.uppercase_ascii id)
               with Not_found -> ID id }
| '\'' (strchr* as str) '\'' { STRING str }
| eof        { EOF }
