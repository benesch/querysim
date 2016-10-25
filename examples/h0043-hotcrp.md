
## HotCRP Query 0043
```sql
select count(*)
from PaperReview
where paperId=?
  and (reviewSubmitted>0
       or reviewNeedsSubmit>0)
```
[examples/h0043-hotcrp.md](/examples/h0043-hotcrp.md)