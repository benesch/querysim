open Algebra
open Printf

let db = new_database ()

let _ =
  add_table db "articles" ["aid"; "title"; "body"];
  add_table db "votes" ["aid"; "uid"];
  add_table db "ratings" ["uid"; "aid"; "n"]

let votes' = Project (
  [{proj_exp = Col (0, 1); proj_alias = None};
   {proj_exp = Col (0, 0); proj_alias = None};
   {proj_exp = Lit "1";    proj_alias = Some "n"}],
  Stored "votes")

let rv = Union (Stored "ratings", votes')

let awv1 =
    Select (
        Binop (Eq, Col (0, 0), Param),
        Group (
            Count,
            [(0, 0); (0, 1); (0, 2)],
            Join ([((0, 0), (1, 0))], Stored "articles", Stored "votes")))

let awv1' =
    Select (
        Binop (Eq, Col (0, 0), Param),
        Group (
            Count,
            [(0, 0); (0, 1); (0, 2)],
            Join ([((1, 1), (0, 0))], Stored "articles", rv)))

let awv2 =
    Select (
        Binop (Eq, Col (0, 0), Param),
        Join (
            [((0, 0), (1, 0))],
            Stored "articles",
            Group (Count, [(0, 0)], Stored "votes")))

let awv2' =
    Select (
        Binop (Eq, Col (0, 0), Param),
        Join (
            [((0, 0), (1, 0))],
            Stored "articles",
            Group (Sum (0, 2), [(0, 1)], rv)))

let _ =
(*  assert_valid db (Stored "articles");
    assert_valid db (Stored "votes");
    assert_valid db (Stored "ratings");
    assert_valid db votes';
    assert_valid db rv;
    assert_valid db awv1;
    assert_valid db awv2; *)
    Soup.show_info db "articles" (database_lookup db "articles");
    Soup.show_info db "votes" (database_lookup db "votes");
    Soup.show_info db "votes'" votes';
    Soup.show_info db "ratings" (database_lookup db "ratings");
    Soup.show_info db "awv1" awv1;
    Soup.show_info db "awv1 optimized" (optimize db awv1);
    Soup.show_info db "awv1'" awv1';
    Soup.show_info db "awv1' optimized" (optimize db awv1');
    Soup.show_info db "awv2" awv2;
    Soup.show_info db "awv2 optimized" (optimize db awv2);
    Soup.show_info db "awv2'" awv2';
    Soup.show_info db "awv2' optimized" (optimize db awv2');

