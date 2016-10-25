
## HotCRP Query 0133
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome,
       Paper.title title,
       Paper.managerContactId managerContactId,
       Paper.leadContactId leadContactId,
       PaperConflict.conflictType conflictType,
       MyReview.reviewType myReviewType,
       MyReview.reviewNeedsSubmit myReviewNeedsSubmit,
       MyReview.reviewSubmitted myReviewSubmitted,
       Paper.abstract abstract,
       Paper.authorInformation authorInformation
from Paper
left join PaperConflict as PaperConflict on (PaperConflict.paperId=Paper.paperId
                                             and (PaperConflict.contactId=?))
left join PaperReview as MyReview on (MyReview.paperId=Paper.paperId
                                      and ((MyReview.contactId=?)))
where (((true)
        or (true)
        or (true))
       and ((true)
            or (true)
            or (true)))
  and Paper.timeSubmitted>0
group by Paper.paperId
```
[examples/h0133-hotcrp.md](/examples/h0133-hotcrp.md)