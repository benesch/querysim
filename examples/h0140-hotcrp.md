
## HotCRP Query 0140
```sql
select ContactInfo.contactId,
       firstName,
       lastName,
       email,
       password,
       contactTags,
       roles,
       defaultWatch,
       PaperReview.reviewType myReviewType,
       PaperReview.reviewSubmitted myReviewSubmitted,
       PaperReview.reviewNeedsSubmit myReviewNeedsSubmit,
       conflictType,
       watch,
       preferredEmail,
       disabled
from ContactInfo
left join PaperConflict on (PaperConflict.paperId=?
                            and PaperConflict.contactId=ContactInfo.contactId)
left join PaperWatch on (PaperWatch.paperId=?
                         and PaperWatch.contactId=ContactInfo.contactId)
left join PaperReview on (PaperReview.paperId=?
                          and PaperReview.contactId=ContactInfo.contactId)
left join PaperComment on (PaperComment.paperId=?
                           and PaperComment.contactId=ContactInfo.contactId)
where watch is not null
  or conflictType>=?
  or reviewType is not null
  or commentId is not null
  or (defaultWatch & ?)!=0
order by conflictType
```
[examples/h0140-hotcrp.md](/examples/h0140-hotcrp.md)