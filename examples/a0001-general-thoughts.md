## General thoughts

* Scanning the log should actually be cheap provided you're not trying to
  reconstruct history and thus bypassing base aggregations.

* Specifying queries up front means we can construct the perfect
  indices!!!

* Perhaps query optimization reduces to finding general but not wholly
  ridiculous joins.
