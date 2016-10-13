open Sql

let _ =
  let query = (Sql_parser.query Sql_lexer.lex (Lexing.from_channel stdin)) in
  print_string (Sql.show_query query)
