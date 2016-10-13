open Algebra
open OUnit2

let parse_query (qstr : string) =
  Sql_parser.query Sql_lexer.lex (Lexing.from_string qstr)

let basic_select ctx = assert_equal
  (parse_query "select name,
       value,
       data
    from Settings")
  (Project ([Col "name"; Col "value"; Col "data"], Table "Settings"))


let filter_select ctx = assert_equal
  (parse_query "select contactId,
       conflictType
    from PaperConflict
    where paperId=?")
  (Project ([Col "contactId"; Col "conflictType"],
    Select ([Equal (Col "paperId", Param)], Table "PaperConflict")))


let order_by ctx = assert_equal
  (parse_query "select topicId,
       topicName
    from TopicArea
    order by topicName")
  (* XXX: Note ORDER BY is not currently represented in our algebra. *)
  (Project ([Col "topicId"; Col "topicName"], Table "TopicArea"))

let select_as ctx = assert_equal
  (parse_query "select PaperComment.*,
       firstName reviewFirstName,
       lastName reviewLastName,
       email reviewEmail
    from PaperComment
    where PaperComment.paperId=?
    order by commentId")
  (* XXX: Note that renaming projects are not currently supported. *)
  (Project ([Col "PaperComment.*"; Col "firstName"; Col "lastName"; Col "email"],
    Select ([Equal (Col "PaperComment.paperId", Param)], Table "PaperComment")))

let simple_join ctx = print_query_nl Hotcrp.db
  (parse_query "select PaperComment.*,
       firstName reviewFirstName,
       lastName reviewLastName,
       email reviewEmail
from PaperComment
join ContactInfo on (ContactInfo.contactId=PaperComment.contactId)
where PaperComment.paperId=?
order by commentId")

let suite = "SQL parsing tests" >:::
  [ "basic select" >:: basic_select
  ; "filter select" >:: filter_select
  ; "order by" >:: order_by
  ; "select as" >:: select_as
  ; "simple join" >:: simple_join
  ]

let _ = run_test_tt_main suite
