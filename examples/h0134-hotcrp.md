
## HotCRP Query 0134
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome,
       PaperConflict.conflictType conflictType,
       Paper.managerContactId managerContactId,
       Paper.leadContactId leadContactId,
       MyReview.reviewType myReviewType,
       MyReview.reviewNeedsSubmit myReviewNeedsSubmit,
       MyReview.reviewSubmitted myReviewSubmitted,

  (select group_concat(' ', tag, '#', tagIndex separator '')
   from PaperTag
   where PaperTag.paperId=Paper.paperId) paperTags
from Paper
left join PaperConflict as PaperConflict on (PaperConflict.paperId=Paper.paperId
                                             and (PaperConflict.contactId=0))
left join PaperReview as MyReview on (MyReview.paperId=Paper.paperId
                                      and ((MyReview.contactId=0)))
where true
  and (PaperConflict.conflictType>=?
       or Paper.paperId=?)
group by Paper.paperId
```
[examples/h0134-hotcrp.md](/examples/h0134-hotcrp.md)