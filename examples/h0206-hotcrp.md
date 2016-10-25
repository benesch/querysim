
## HotCRP Query 0206
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
       PaperReview.reviewerQualification as reviewerQualification,
       PaperReview.commentsToAddress as commentsToAddress,
       PaperReview.paperSummary as paperSummary,
       PaperReview.strengthOfPaper as strengthOfPaper,
       PaperReview.grammar as grammar,
       PaperReview.fixability as fixability,
       PaperReview.commentsToAuthor as commentsToAuthor,
       PaperReview.textField7 as textField7,
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
[examples/h0206-hotcrp.md](/examples/h0206-hotcrp.md)