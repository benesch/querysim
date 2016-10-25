
## HotCRP Query 0039
```sql
select coalesce(max(reviewOrdinal), 0)
from PaperReview
where paperId=?
group by paperId
```
[examples/h0039-hotcrp.md](/examples/h0039-hotcrp.md)