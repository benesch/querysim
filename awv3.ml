open Algebra

let db = new_database ()

let _ =
  add_table db "article" ["id"; "title"];
  add_table db "vote" ["user"; "id"];

  add_external_sql db "awvc"
    "SELECT id, title, votes FROM article LEFT JOIN (
       SELECT id, COUNT(user) as votes FROM vote GROUP BY id
     ) as votecount USING (id)";

  split_database db;
  print_database db;
  Yojson.Basic.pretty_to_channel stdout (json_of_database db)
