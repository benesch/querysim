open Algebra
open OUnit

let test_string_of_exp _ =
  let e = Binop (And,
    Binop (Or, Binop (Eq, Col "a", Col "b"), Binop (Eq, Col "c", Col "d")),
    Binop (Eq, Col "b", Col "d"))
  in
  assert_equal (string_of_exp e) "(((a = b) OR (c = d)) AND (b = d))"

let test_exps_equal1 _ =
  let e1 = Col "a" in
  let e2 = Col "a" in
  assert (exps_equal e1 e2)

let test_exps_equal2 _ =
  let e1 = Binop (Eq, Col "a", Col "b") in
  let e2 = Binop (Eq, Col "a", Col "b") in
  assert (exps_equal e1 e2)

let test_exps_equal3 _ =
  let e1 = Binop (Eq, Col "a", Col "b") in
  let e2 = Binop (Eq, Col "b", Col "a") in
  assert (exps_equal e1 e2)

let suite = "expressions" >:::
  ["test_string_of_exp" >:: test_string_of_exp;
   "test_exps_equal1" >:: test_exps_equal1;
   "test_exps_equal2" >:: test_exps_equal2;
   "test_exps_equal3" >:: test_exps_equal3]

