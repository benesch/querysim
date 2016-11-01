let filteri pred =
  let rec f i memo = function
    | [] -> List.rev memo
    | hd :: tl ->
        if pred i hd then f (i + 1) (hd :: memo) tl else f (i + 1) memo tl
  in
  f 0 []

let rec findi i pred = function
  | [] -> raise Not_found
  | hd :: tl -> if pred hd then i else findi (i + 1) pred tl

let findi pred = findi 0 pred
