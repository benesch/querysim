open Algebra

let db = new_database ()

let _ =
  add_table db "users" ["uid"; "country"];
  add_table db "orders" ["iid"; "uid"; "date"; "status"];
  add_table db "items" ["iid"; "available"; "price"; "category"];

(*   add_external_sql db "Q1"
    "SELECT country, COUNT(uid) FROM users GROUP BY country"; *)

  add_external_sql db "OkOrders"
    "SELECT * FROM users JOIN orders USING (uid) WHERE status = 'OK'";

  add_external_sql db "ReadyOrders"
    "SELECT * FROM users JOIN orders USING (uid) JOIN items USING (iid)
     WHERE available = true";

  add_external_sql db "ItemsOnDate"
    "SELECT * FROM orders JOIN items USING (iid) WHERE date = 'some date'";

(*   add_external_sql db "Q5"
    "SELECT * FROM items WHERE category = 'some cat'"; *)

  Soup.do_magic db
