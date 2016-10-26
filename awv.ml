open Algebra
open Printf

let awv_db = new_database ()

let _ =
  add_table awv_db "articles" ["aid"; "title"; "body"];
  add_table awv_db "votes" ["aid"; "uid"];
  add_table awv_db "ratings" ["uid"; "aid"; "n"]

let votes' = Project (
  [{pexp = Col "aid"; alias = None};
   {pexp = Col "uid"; alias = None};
   {pexp = Lit "1"; alias = Some "n"}],
  Table "votes")
let rv = Union (Table "ratings", votes')

let awv1 =
    Select (
        Binop (Eq, Col "aid", Param),
        Group (
            [Count],
            ["aid"; "title"; "body"],
            Join (Col "aid", Table "articles", Table "votes")))

let awv1' =
    Select (
        Binop (Eq, Col "aid", Param),
        Group (
            [Count],
            ["aid"; "title"; "body"],
            Join (Col "aid", Table "articles", rv)))
let awv2 =
    Select (
        Binop (Eq, Col "aid", Param),
        Join (
            Col "aid",
            Table "articles",
            Group ([Count], ["aid"], Table "votes")))

let awv2' =
    Select (
        Binop (Eq, Col "aid", Param),
        Join (
            Col "aid",
            Table "articles",
            Group ([Sum "n"], ["aid"], rv)))
let _ =
    assert_valid awv_db (Table "articles");
    assert_valid awv_db (Table "votes");
    assert_valid awv_db (Table "ratings");
    assert_valid awv_db votes';
    assert_valid awv_db rv;
    assert_valid awv_db awv1;
    assert_valid awv_db awv2;

    print_endline "articles";
    print_query_nl awv_db (Table "articles");
    print_endline "votes";
    print_query_nl awv_db (Table "votes");
    print_endline "votes'";
    print_query_nl awv_db votes';
    print_endline "ratings";
    print_query_nl awv_db (Table "ratings");
    print_endline "rv";
    print_query_nl awv_db rv;

    print_endline "awv1";
    print_query_nl awv_db awv1;
    print_endline "awv1 after optimization";
    print_query_nl awv_db (optimize awv_db awv1);
    print_endline "awv1'";
    print_query_nl awv_db awv1';
    print_endline "awv1' after optimization";
    print_query_nl awv_db (optimize awv_db awv1');

    print_endline "awv2";
    print_query_nl awv_db awv2;
    print_endline "awv2 after optimization";
    print_query_nl awv_db (optimize awv_db awv2);
    print_endline "awv2'";
    print_query_nl awv_db awv2';
    print_endline "awv2' after optimization";
    print_query_nl awv_db (optimize awv_db awv2');
