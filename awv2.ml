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

  optimize_db db;
  split_database db;
  print_database db;
  Unix.chdir "../distributary";
  let proc_in = Unix.open_process_out "./jdl2png.sh" in
  Yojson.Basic.pretty_to_channel proc_in (json_of_database db);
  Unix.close_process_out proc_in
