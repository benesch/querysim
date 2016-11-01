open OUnit

let suite = "querysim" >:::
  [(* Test_exp.suite; *)
   Test_util.suite]

let _ =
  run_test_tt_main suite
