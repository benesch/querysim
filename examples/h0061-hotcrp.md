
## HotCRP Query 0061
```sql
select paperId
from PaperReview
where reviewType>?
  and timeRequested>timeRequestNotified
  and reviewSubmitted is null
  and reviewNeedsSubmit!=0 limit 1
```
[examples/h0061-hotcrp.md](/examples/h0061-hotcrp.md)