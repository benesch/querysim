open OUnit

let test_findi _ =
  assert_equal (Util.findi ((<) 5) [-5; 4; 5; 6; 9; 12]) 3

let suite = "util" >:::
  ["test_findi" >:: test_findi]
