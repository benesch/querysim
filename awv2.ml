open Algebra

let db = new_database ()

let _ =
  add_table db "Article" ["aid"; "uid"; "title"; "body"; "ts"];
  add_table db "Vote" ["aid"; "uid"; "ts"];
  add_table db "User" ["name"; "uid"];

  add_external_sql db "ArticlesWithVotes"
    "SELECT * FROM Article LEFT JOIN (
       SELECT COUNT(uid) AS votes, aid FROM Vote GROUP BY aid
     ) as VoteCount USING (aid)
     WHERE aid = ?";

  add_external_sql db "ArticlesWithUsersAndVotes"
    "SELECT * FROM Article LEFT JOIN (
       SELECT COUNT(uid) AS votes, aid FROM Vote GROUP BY aid
     ) as VoteCount USING (aid)
     LEFT JOIN User USING (uid)
     WHERE aid = ?";

  add_external_sql db "NewArticlesWithVotes"
    "SELECT * FROM Article LEFT JOIN (
       SELECT COUNT(uid) AS votes, aid FROM Vote GROUP BY aid
     ) as VoteCount USING (aid)
     WHERE ts < ?";

  add_external_sql db "VotesOnArticle"
    "SELECT COUNT(uid) FROM Vote WHERE aid = ?";

  add_external_sql db "UserHasVoted"
    "SELECT * FROM Vote WHERE aid = ? AND uid = ?";

  split_database db;
  print_database db;
  Yojson.Basic.pretty_to_channel stdout (json_of_database db)
