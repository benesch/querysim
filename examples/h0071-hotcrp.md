
## HotCRP Query 0071
```sql
select PaperReview.contactId,
       timeRequested,
       reviewSubmitted,
       reviewRound,
       0 conflictType
from PaperReview
where reviewType>?
  or (reviewType=?
      and timeRequested>0
      and reviewSubmitted>0)
```
[examples/h0071-hotcrp.md](/examples/h0071-hotcrp.md)