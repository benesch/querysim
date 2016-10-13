{
open Lexing
open Sql_parser

let next_line lexbuf =
  let pos = lexbuf.lex_curr_p in
  lexbuf.lex_curr_p <-
    { pos with pos_lnum = pos.pos_lnum + 1;
               pos_bol = pos.pos_cnum;
    }

let keywords = Hashtbl.create 12
let _ = List.iter
  (fun (kw, tok) -> Hashtbl.add keywords kw tok)
  [ "AND", AND
  ; "AS", AS
  ; "BY", BY
  ; "DELETE", DELETE
  ; "FROM", FROM
  ; "GROUP", GROUP
  ; "INSERT", INSERT
  ; "JOIN", JOIN
  ; "OR", OR
  ; "ON", ON
  ; "ORDER", ORDER
  ; "SELECT", SELECT
  ; "SET", SET
  ; "UPDATE", UPDATE
  ; "WHERE", WHERE
  ]
}

let whitespace = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let id = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '.' '*']*
let int = '-'? ['0'-'9']+

rule lex = parse
| whitespace { lex lexbuf }
| newline    { next_line lexbuf; lex lexbuf }
| int        { INT (int_of_string (Lexing.lexeme lexbuf)) }
| ','        { COMMA }
| '='        { EQUALS }
| '?'        { QMARK }
| '('        { LPAREN }
| ')'        { RPAREN }
| id+ as id  { try Hashtbl.find keywords (String.uppercase id)
               with Not_found -> ID id }
| eof        { EOF }
