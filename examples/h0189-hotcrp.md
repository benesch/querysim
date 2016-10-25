
## HotCRP Query 0189
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

  (select group_concat(topicId)
   from PaperTopic
   where PaperTopic.paperId=Paper.paperId) topicIds,

  (select group_concat(PaperOption.optionId, '#', value)
   from PaperOption
   where paperId=Paper.paperId) optionIds,

  (select group_concat(' ', tag, '#', tagIndex
                       order by tag separator '')
   from PaperTag
   where PaperTag.paperId=Paper.paperId) paperTags,
       coalesce(PaperReviewPreference.preference, 0) as reviewerPreference,
       PaperReviewPreference.expertise as reviewerExpertise
from Paper
left join PaperConflict on (PaperConflict.paperId=Paper.paperId
                            and PaperConflict.contactId=?)
left join PaperReview on (PaperReview.paperId=Paper.paperId
                          and PaperReview.contactId=?)
left join PaperReviewPreference on (PaperReviewPreference.paperId=Paper.paperId
                                    and PaperReviewPreference.contactId=?)
where Paper.paperId=?
group by Paper.paperId
order by Paper.paperId
```
[examples/h0189-hotcrp.md](/examples/h0189-hotcrp.md)