open Algebra
open Printf


let awv_db = new_database ()

let _ =
    add_table awv_db "articles" [Col "aid"; Col "title"; Col "body"];
    add_table awv_db "votes" [Col "aid"; Col "uid"];
    add_table awv_db "ratings" [Col "uid"; Col "aid"; Col "n"]

let votes' = Project ([Col "aid"; Col "uid"; Lit ("n", "1")], Table "votes")
let rv = Union (Table "ratings", votes')

let awv1 =
    Select (
        [Equal (Col "aid", Param)],
        Group (
            [Count],
            [Col "aid"; Col "title"; Col "body"],
            Equijoin ([Col "aid"], Table "articles", Table "votes")))
let awv1' =
    Select (
        [Equal (Col "aid", Param)],
        Group (
            [Count],
            [Col "aid"; Col "title"; Col "body"],
            Equijoin ([Col "aid"], Table "articles", rv)))
let awv2 =
    Select (
        [Equal (Col "aid", Param)],
        Equijoin (
            [Col "aid"],
            Table "articles",
            Group ([Count], [Col "aid"], Table "votes")))

let awv2' =
    Select (
        [Equal (Col "aid", Param)],
        Equijoin (
            [Col "aid"],
            Table "articles",
            Group ([Sum (Col "n")], [Col "aid"], rv)))

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

(*let users = Table [Col "uid"; Col "name"; Col "email"; Col "banned"] ;;
let comments = Table [Col "aid"; Col "uid"; Col "text"] ;;
let articles_comments = Equijoin ([Col "uid"], users, comments) ;;
let article_comments = Select (
    [Equal (Col "aid", Param); Equal (Col "banned", Lit ("banned", "yes"))],
    articles_comments) ;;

print_endline "users" ;;
print_query_nl users ;;
print_endline "comments" ;;
print_query_nl comments ;;
print_endline "article_comments" ;;
print_query_nl article_comments ;;
print_endline "selections pushed" ;;
print_query_nl (optimize article_comments)


let sample =
    Equijoin (
        [Col "a"],
        Table [Col "a"; Col "d"],
        Union (
            Project (
                [Col "a"],
                Select (
                    [Equal (Col "a", Col "b")],
                    Table [Col "a"; Col "b"])),
            Group (
                [Sum (Col "b")],
                [Col "a"],
                Select (
                    [Equal (Col "a", Col "b")],
                    Table [Col "a"; Col "b"]))))
*)
