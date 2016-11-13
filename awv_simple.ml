open Algebra

let db = new_database ()

let _ =
  add_table db "article" ["id"; "user"; "title"; "url"];
  add_table db "vote" ["id"; "user"];

  add_external_sql db "awvc"
    "SELECT * FROM article LEFT JOIN (
       SELECT COUNT(user) AS votes, id FROM vote GROUP BY id
     ) as VoteCount USING (id)";

  add_external_sql db "karma"
    "SELECT user, SUM(votes) as votes FROM article LEFT JOIN (
       SELECT COUNT(user) AS votes, id FROM vote GROUP BY id
    ) as VoteCount USING (id)
    GROUP BY user";

  split_database db;
  (* print_database db; *)
  Yojson.Basic.pretty_to_channel stdout (json_of_database db)
