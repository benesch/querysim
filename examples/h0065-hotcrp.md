
## HotCRP Query 0065
```sql
select r.reviewId
from PaperReview r
join Paper p on (p.paperId=r.paperId
                 and p.timeSubmitted>0)
where (r.contactId=?)
  and r.reviewNeedsSubmit!=0 limit 1
```
[examples/h0065-hotcrp.md](/examples/h0065-hotcrp.md)