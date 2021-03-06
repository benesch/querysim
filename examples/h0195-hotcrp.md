
## HotCRP Query 0195
```sql
select Paper.*,
       PaperConflict.conflictType,
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
       PaperReview.reviewEditVersion as reviewEditVersion,
       PaperReview.reviewFormat as reviewFormat,
       PaperReview.overAllMerit as overAllMerit,
       PaperReview.reviewerQualification as reviewerQualification,
       PaperReview.fixability as fixability,
       PaperReview.paperSummary as paperSummary,
       PaperReview.commentsToAuthor as commentsToAuthor,
       PaperReview.commentsToPC as commentsToPC,

  (select group_concat(PaperOption.optionId, '#', value)
   from PaperOption
   where paperId=Paper.paperId) optionIds,

  (select group_concat(' ', tag, '#', tagIndex
                       order by tag separator '')
   from PaperTag
   where PaperTag.paperId=Paper.paperId) paperTags
from Paper
left join PaperConflict on (PaperConflict.paperId=Paper.paperId
                            and PaperConflict.contactId=?)
join PaperReview on (PaperReview.paperId=Paper.paperId
                     and PaperReview.contactId=?)
where timeWithdrawn<=0
group by Paper.paperId,
         PaperReview.reviewId
order by Paper.paperId,
         PaperReview.reviewOrdinal
```
[examples/h0195-hotcrp.md](/examples/h0195-hotcrp.md)