
## HotCRP Query 0060
```sql
select reviewId,
       reviewType,
       reviewRound,
       reviewModified,
       reviewToken,
       requestedBy,
       reviewSubmitted
from PaperReview
where paperId=?
  and contactId=?
```
[examples/h0060-hotcrp.md](/examples/h0060-hotcrp.md)