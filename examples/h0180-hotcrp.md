
## HotCRP Query 0180
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome,
       Reviews_AllComplete.info Reviews_AllComplete_info,
       Paper.managerContactId managerContactId,
       Paper.leadContactId leadContactId,
       PaperConflict.conflictType conflictType,
       MyReview.reviewType myReviewType,
       MyReview.reviewNeedsSubmit myReviewNeedsSubmit,
       MyReview.reviewSubmitted myReviewSubmitted,

  (select group_concat(' ', tag, '#', tagIndex separator '')
   from PaperTag
   where PaperTag.paperId=Paper.paperId) paperTags
from Paper
left join
  (select r.paperId,
          count(r.reviewId) count,
                            group_concat(r.reviewId, ' ', r.contactId, ' ', r.reviewType, ' ', coalesce(r.reviewSubmitted,0), ' ', r.reviewNeedsSubmit, ' ', r.requestedBy, ' ', r.reviewToken, ' ', r.reviewBlind) info
   from PaperReview r
   where (reviewSubmitted>0)
   group by paperId) as Reviews_AllComplete on (Reviews_AllComplete.paperId=Paper.paperId)
left join PaperConflict as PaperConflict on (PaperConflict.paperId=Paper.paperId
                                             and (PaperConflict.contactId=?))
left join PaperReview as MyReview on (MyReview.paperId=Paper.paperId
                                      and ((MyReview.contactId=?)))
where (coalesce(Reviews_AllComplete.count,0)>=0)
  and Paper.timeSubmitted>0
group by Paper.paperId
```
[examples/h0180-hotcrp.md](/examples/h0180-hotcrp.md)