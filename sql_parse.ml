let _ =
  Sql.show_query
    (Sql_parser.query Sql_lexer.lex (Lexing.from_channel stdin))
