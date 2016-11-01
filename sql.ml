include Sql_types

let parse_string s =
  Sql_parser.query Sql_lexer.lex (Lexing.from_string s)

let parse_channel c =
  Sql_parser.query Sql_lexer.lex (Lexing.from_channel c)
