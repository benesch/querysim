
## HotCRP Query 0184
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
       PaperReview.paperSummary as paperSummary,
       PaperReview.commentsToAddress as commentsToAddress,
       PaperReview.commentsToAuthor as commentsToAuthor,
       PaperReview.commentsToPC as commentsToPC
from Paper
left join PaperConflict on (PaperConflict.paperId=Paper.paperId
                            and PaperConflict.contactId=?)
left join PaperReview on (PaperReview.paperId=Paper.paperId
                          and PaperReview.contactId=?)
where Paper.paperId in (?)
group by Paper.paperId,
         PaperReview.reviewId
order by Paper.paperId,
         PaperReview.reviewOrdinal
```
[examples/h0184-hotcrp.md](/examples/h0184-hotcrp.md)