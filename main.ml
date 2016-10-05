open Algebra
open Printf


let articles = Table [Col "aid"; Col "title"; Col "body"]
let votes = Table [Col "aid"; Col "uid"]
let awv1 =
    Select (
        [Equal (Col "aid", Param)],
        Group (
            [Count],
            [Col "aid"; Col "title"; Col "body"],
            Equijoin ([Col "aid"], articles, votes)))
let awv2 =
    Select (
        [Equal (Col "aid", Param)],
        Equijoin (
            [Col "aid"],
            articles,
            Group ([Count], [Col "aid"], votes))) ;;

assert_valid awv1 ;;

print_endline "awv1" ;;
print_query_nl awv1 ;;
print_endline "awv2" ;;
print_query_nl awv2 ;;


let users = Table [Col "uid"; Col "name"; Col "email"; Col "banned"] ;;
let comments = Table [Col "aid"; Col "uid"; Col "text"] ;;
let articles_comments = Equijoin ([Col "uid"], users, comments) ;;
let article_comments = Select (
    [Equal (Col "aid", Param); Equal (Col "banned", Lit "yes")],
    articles_comments) ;;

print_endline "users" ;;
print_query_nl users ;;
print_endline "comments" ;;
print_query_nl comments ;;
print_endline "article_comments" ;;
print_query_nl article_comments ;;
print_endline "selections pushed" ;;
print_query_nl (push_selects article_comments)


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
