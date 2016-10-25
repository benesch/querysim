
## HotCRP Query 0141
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome,
       PaperConflict.conflictType conflictType,
       MyReview.reviewType myReviewType,
       MyReview.reviewNeedsSubmit myReviewNeedsSubmit,
       MyReview.reviewSubmitted myReviewSubmitted,
       Paper.managerContactId managerContactId,
       Paper.leadContactId leadContactId,

  (select group_concat(' ', tag, '#', tagIndex separator '')
   from PaperTag
   where PaperTag.paperId=Paper.paperId) paperTags
from Paper
left join PaperConflict as PaperConflict on (PaperConflict.paperId=Paper.paperId
                                             and (PaperConflict.contactId=?))
left join PaperReview as MyReview on (MyReview.paperId=Paper.paperId
                                      and ((MyReview.contactId=?)))
where true
  and (PaperConflict.conflictType>=?
       or (Paper.timeWithdrawn<=0
           and MyReview.reviewType is not null))
group by Paper.paperId
```
[examples/h0141-hotcrp.md](/examples/h0141-hotcrp.md)