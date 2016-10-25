
## HotCRP Query 0103
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
left join PaperConflict on (PaperConflict.paperId=Paper.paperId
                            and PaperConflict.contactId=0)
where Paper.paperId in (?)
group by Paper.paperId
order by Paper.paperId
```
[examples/h0103-hotcrp.md](/examples/h0103-hotcrp.md)