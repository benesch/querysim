
## HotCRP Query 0147
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome,
       Paper.managerContactId managerContactId,
       Paper.leadContactId leadContactId,
       PaperConflict.conflictType conflictType,
       MyReview.reviewType myReviewType,
       MyReview.reviewNeedsSubmit myReviewNeedsSubmit,
       MyReview.reviewSubmitted myReviewSubmitted,
       count(Tag_3.tag) Tag_3_ct,

  (select group_concat(' ', tag, '#', tagIndex separator '')
   from PaperTag
   where PaperTag.paperId=Paper.paperId) paperTags
from Paper
left join PaperConflict as PaperConflict on (PaperConflict.paperId=Paper.paperId
                                             and (PaperConflict.contactId=?))
left join PaperReview as MyReview on (MyReview.paperId=Paper.paperId
                                      and ((MyReview.contactId=?)))
left join PaperTag as Tag_3 on (Tag_3.paperId=Paper.paperId
                                and (Tag_3.tag=?))
where (Tag_3.tag is not null)
  and Paper.timeSubmitted>0
group by Paper.paperId
```
[examples/h0147-hotcrp.md](/examples/h0147-hotcrp.md)