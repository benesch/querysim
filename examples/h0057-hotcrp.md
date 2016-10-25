
## HotCRP Query 0057
```sql
select
  (select max(conflictType)
   from PaperConflict
   where contactId=?),
  (select paperId
   from PaperReview
   where contactId=? limit 1)
```
[examples/h0057-hotcrp.md](/examples/h0057-hotcrp.md)