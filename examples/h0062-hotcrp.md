
## HotCRP Query 0062
```sql
select
  (select max(conflictType)
   from PaperConflict
   where contactId=?),
  (select paperId
   from PaperReview
   where contactId=?
     or reviewToken in ? limit 1)
```
[examples/h0062-hotcrp.md](/examples/h0062-hotcrp.md)