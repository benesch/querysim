
## HotCRP Query 0151
```sql
select Paper.*,
       PaperConflict.conflictType,

  (select count(*)
   from PaperReview
   where paperId=Paper.paperId
     and (reviewSubmitted>0
          or reviewNeedsSubmit>0)) startedReviewCount,

  (select count(*)
   from PaperReview
   where paperId=Paper.paperId
     and (reviewSubmitted>0
          or reviewModified>0)) inProgressReviewCount,
       coalesce(R_submitted.count,0) reviewCount,
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
left join
  (select paperId,
          count(*) count
   from PaperReview
   where reviewSubmitted>0
   group by paperId) R_submitted on (R_submitted.paperId=Paper.paperId)
group by Paper.paperId
order by Paper.paperId
```
[examples/h0151-hotcrp.md](/examples/h0151-hotcrp.md)