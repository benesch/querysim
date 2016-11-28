open Algebra

let make_png db =
  Unix.chdir "../distributary";
  let proc_in = Unix.open_process_out "./jdl2png.sh" in
  Yojson.Basic.pretty_to_channel proc_in (Jdl.jdl_of_database db);
  assert (Unix.close_process_out proc_in = Unix.WEXITED 0)

let make_json db =
  Yojson.Basic.pretty_to_channel stdout (Jdl.jdl_of_database db)

let do_magic db =
  optimize_db db;
  split_database db;
  print_database db;
  make_json db;
  make_png db
