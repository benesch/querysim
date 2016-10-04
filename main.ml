open Algebra
open Printf

let c =  Algebra.Col "a"
let _ = print_query (
  Join(
    Equals (Col "a", Col "a"),
    Table [Col "a"; Col "d"],
    Union (
      Project (
        [Col "a"],
        Select (
          Equals (Col "a", Col "b"),
          Table [Col "a"; Col "b"])),
      Group (
        [Sum (Col "b")],
        [Col "a"],
        Select (
          Equals (Col "a", Col "b"),
          Table [Col "a"; Col "b"])))))
