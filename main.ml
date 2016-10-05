open Algebra
open Printf


let articles = Table [Col "aid"; Col "title"; Col "body"] ;;
let votes = Table [Col "aid"; Col "uid"] ;;
let votes' = Project ([Col "aid"; Col "uid"; Lit ("n", "1")], votes) ;;
let rating = Table [Col "uid"; Col "aid"; Col "n"] ;;
let rv = Union (rating, votes') ;;

let awv1 =
    Select (
        [Equal (Col "aid", Param)],
        Group (
            [Count],
            [Col "aid"; Col "title"; Col "body"],
            Equijoin ([Col "aid"], articles, votes)))
let awv1' =
    Select (
        [Equal (Col "aid", Param)],
        Group (
            [Count],
            [Col "aid"; Col "title"; Col "body"],
            Equijoin ([Col "aid"], articles, rv)))
let awv2 =
    Select (
        [Equal (Col "aid", Param)],
        Equijoin (
            [Col "aid"],
            articles,
            Group ([Count], [Col "aid"], votes))) ;;

let awv2' =
    Select (
        [Equal (Col "aid", Param)],
        Equijoin (
            [Col "aid"],
            articles,
            Group ([Sum (Col "n")], [Col "aid"], rv))) ;;

assert_valid articles ;;
assert_valid votes ;;
assert_valid votes' ;;
assert_valid rating ;;
assert_valid rv ;;
assert_valid awv1 ;;
assert_valid awv2 ;;

print_endline "articles" ;;
assert_valid articles ;;
print_endline "votes" ;;
print_query_nl votes ;;
print_endline "votes'" ;;
print_query_nl votes' ;;
print_endline "rating" ;;
print_query_nl rating ;;
print_endline "rv" ;;
print_query_nl rv ;;

print_endline "awv1" ;;
print_query_nl awv1 ;;
print_endline "awv1 after optimization" ;;
print_query_nl (optimize awv1) ;;
print_endline "awv1'" ;;
print_query_nl awv1' ;;
print_endline "awv1' after optimization" ;;
print_query_nl (optimize awv1') ;;

print_endline "awv2" ;;
print_query_nl awv2 ;;
print_endline "awv2 after optimization" ;;
print_query_nl (optimize awv2) ;;
print_endline "awv2'" ;;
print_query_nl awv2' ;;
print_endline "awv2' after optimization" ;;
print_query_nl (optimize awv2') ;;

let users = Table [Col "uid"; Col "name"; Col "email"; Col "banned"] ;;
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
