
## HotCRP Query 0120
```sql
select Paper.*,
       PaperConflict.conflictType,
       null reviewType,
            null reviewId,
                 null myReviewType,

  (select group_concat(PaperOption.optionId, '#', value)
   from PaperOption
   where paperId=Paper.paperId) optionIds,

  (select group_concat(' ', tag, '#', tagIndex
                       order by tag separator '')
   from PaperTag
   where PaperTag.paperId=Paper.paperId) paperTags
from Paper
join PaperConflict on (PaperConflict.paperId=Paper.paperId
                       and PaperConflict.contactId=?
                       and PaperConflict.conflictType>=?)
group by Paper.paperId
order by Paper.paperId
```
[examples/h0120-hotcrp.md](/examples/h0120-hotcrp.md)