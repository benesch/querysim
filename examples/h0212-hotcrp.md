
## HotCRP Query 0212
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
       PaperReview.overAllMerit,
       R_submitted.reviewerQualificationScores,
       PaperReview.reviewerQualification,
       R_submitted.reviewContactIds,
       PaperReview.reviewType,
       PaperReview.reviewId,
       PaperReview.reviewModified,
       PaperReview.reviewSubmitted,
       PaperReview.timeApprovalRequested,
       PaperReview.reviewNeedsSubmit,
       PaperReview.reviewOrdinal,
       PaperReview.reviewBlind,
       PaperReview.reviewToken,
       PaperReview.timeRequested,
       PaperReview.contactId as reviewContactId,
       PaperReview.requestedBy,
       max(PaperReview.reviewType) as myReviewType,
       max(PaperReview.reviewSubmitted) as myReviewSubmitted,
       min(PaperReview.reviewNeedsSubmit) as myReviewNeedsSubmit,
       PaperReview.contactId as myReviewContactId,
       PaperReview.reviewRound,

  (select group_concat(PaperOption.optionId, '#', value)
   from PaperOption
   where paperId=Paper.paperId) optionIds
from Paper
left join PaperConflict on (PaperConflict.paperId=Paper.paperId
                            and PaperConflict.contactId=?)
left join PaperReview on (PaperReview.paperId=Paper.paperId
                          and PaperReview.contactId=?)
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
   where paperId in (?)
     and reviewSubmitted>0
   group by paperId) R_submitted on (R_submitted.paperId=Paper.paperId)
where Paper.paperId in (?)
group by Paper.paperId
order by Paper.paperId
```
[examples/h0212-hotcrp.md](/examples/h0212-hotcrp.md)