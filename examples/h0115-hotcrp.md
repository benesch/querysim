
## HotCRP Query 0115
```sql
select Paper.*,
       PaperConflict.conflictType,
       null reviewType,
            null reviewId,
                 null myReviewType,

  (select group_concat(topicId)
   from PaperTopic
   where PaperTopic.paperId=Paper.paperId) topicIds,

  (select group_concat(PaperOption.optionId, '#', value)
   from PaperOption
   where paperId=Paper.paperId) optionIds
from Paper
left join PaperConflict on (PaperConflict.paperId=Paper.paperId
                            and PaperConflict.contactId=0)
where Paper.paperId=?
group by Paper.paperId
order by Paper.paperId
```
[examples/h0115-hotcrp.md](/examples/h0115-hotcrp.md)