
## HotCRP Query 0157
```sql
select Paper.*,
       PaperConflict.conflictType,

  (select count(*)
   from PaperReview
   where paperId=Paper.paperId
     and (reviewSubmitted>0
          or reviewModified>0)) inProgressReviewCount,
       coalesce(R_submitted.count,0) reviewCount,
       R_submitted.overAllMeritScores,
       R_submitted.reviewerQualificationScores,
       R_submitted.reviewContactIds,
       null reviewType,
            null reviewId,
                 null myReviewType,

  (select group_concat(PaperOption.optionId, '#', value)
   from PaperOption
   where paperId=Paper.paperId) optionIds
from Paper
left join PaperConflict on (PaperConflict.paperId=Paper.paperId
                            and PaperConflict.contactId=0)
left join
  (select paperId,
          count(*) count,
                   group_concat(overAllMerit
                                order by reviewId) overAllMeritScores,
                   group_concat(reviewerQualification
                                order by reviewId) reviewerQualificationScores,
                   group_concat(contactId
                                order by reviewId) reviewContactIds
   from PaperReview
   where paperId=?
     and reviewSubmitted>0
   group by paperId) R_submitted on (R_submitted.paperId=Paper.paperId)
where Paper.paperId=?
group by Paper.paperId
order by Paper.paperId
```
[examples/h0157-hotcrp.md](/examples/h0157-hotcrp.md)