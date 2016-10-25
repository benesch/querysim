
## HotCRP Query 0104
```sql
select Paper.*,
       PaperConflict.conflictType,
       null reviewType,
            null reviewId,
                 null myReviewType,

  (select group_concat(PaperOption.optionId, '#', value)
   from PaperOption
   where paperId=Paper.paperId) optionIds
from Paper
join PaperConflict on (PaperConflict.paperId=Paper.paperId
                       and PaperConflict.contactId=?
                       and PaperConflict.conflictType>=?)
group by Paper.paperId
order by Paper.paperId
```
[examples/h0104-hotcrp.md](/examples/h0104-hotcrp.md)