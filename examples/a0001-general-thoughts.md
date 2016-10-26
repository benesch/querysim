## General thoughts

* Scanning the log should actually be cheap provided you're not trying to
  reconstruct history and thus bypassing base aggregations.

* Specifying queries up front means we can construct the perfect
  indices!!!

* Perhaps query optimization reduces to finding general but not wholly
  ridiculous joins.

## Current strategy

Input: a set of SQL queries and table schemas.

Output: a set of named Soup algebra queries that can refer to other
named queries. (Assuming transforming these into a Soup graph is
straightforward as the Soup algebra is designed for this.)

Optimize for the lowest number of total operations.

Current algorithm. Phase one: push selects and groupings. Pull out any
obviously equivalent queries. Phase two: find containing joins. 

