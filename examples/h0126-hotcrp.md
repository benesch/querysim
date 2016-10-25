
## HotCRP Query 0126
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome,
       Paper.managerContactId managerContactId,
       Paper.leadContactId leadContactId,
       count(Tag_1.tag) Tag_1_ct,
       PaperConflict.conflictType conflictType,
       MyReview.reviewType myReviewType,
       MyReview.reviewNeedsSubmit myReviewNeedsSubmit,
       MyReview.reviewSubmitted myReviewSubmitted
from Paper
left join PaperTag as Tag_1 on (Tag_1.paperId=Paper.paperId
                                and (Tag_1.tag=?))
left join PaperConflict as PaperConflict on (PaperConflict.paperId=Paper.paperId
                                             and (PaperConflict.contactId=?))
left join PaperReview as MyReview on (MyReview.paperId=Paper.paperId
                                      and ((MyReview.contactId=?)))
where (Tag_1.tag is not null)
group by Paper.paperId
```
[examples/h0126-hotcrp.md](/examples/h0126-hotcrp.md)