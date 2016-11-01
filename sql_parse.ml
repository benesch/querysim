let _ =
  print_string (Sql.show_query (Sql.parse_channel stdin))
