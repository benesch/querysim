
## HotCRP Query 0090
```sql
select Paper.*,
       PaperConflict.conflictType,
       null reviewType,
            null reviewId,
                 null myReviewType
from Paper
left join PaperConflict on (PaperConflict.paperId=Paper.paperId
                            and PaperConflict.contactId=0)
where Paper.paperId=?
group by Paper.paperId
order by Paper.paperId
```
[examples/h0090-hotcrp.md](/examples/h0090-hotcrp.md)