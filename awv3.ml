open Algebra

let db = new_database ()

let _ =
  add_table db "article" ["id"; "user"; "title"; "url"];
  add_table db "vote" ["id"; "user"];

  add_external_sql db "awvc"
    "SELECT * FROM article LEFT JOIN (
       SELECT COUNT(user) AS votes, id FROM vote GROUP BY id
     ) as VoteCount USING (id)
     WHERE id = ?";

  add_external_sql db "karma"
    "SELECT user, SUM(votes) as votes FROM article LEFT JOIN (
       SELECT COUNT(user) AS votes, id FROM vote GROUP BY id
    ) as VoteCount USING (id)
    GROUP BY user";

(*   add_external_sql db "VotesOnArticle"
    "SELECT COUNT(user) FROM vote WHERE id = ?"; *)

  Soup.do_magic db
