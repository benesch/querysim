
## HotCRP Query 0036
```sql
select requestedBy
from PaperReview
where requestedBy=?
  and contactId!=? limit 1
```
[examples/h0036-hotcrp.md](/examples/h0036-hotcrp.md)