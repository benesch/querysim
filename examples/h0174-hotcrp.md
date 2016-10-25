
## HotCRP Query 0174
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome,
       Reviews_ExternalApprovable.info Reviews_ExternalApprovable_info,
       Paper.managerContactId managerContactId,
       Paper.leadContactId leadContactId,
       PaperConflict.conflictType conflictType,
       MyReview.reviewType myReviewType,
       MyReview.reviewNeedsSubmit myReviewNeedsSubmit,
       MyReview.reviewSubmitted myReviewSubmitted
from Paper
left join
  (select r.paperId,
          count(r.reviewId) count,
                            group_concat(r.reviewId, ' ', r.contactId, ' ', r.reviewType, ' ', coalesce(r.reviewSubmitted,0), ' ', r.reviewNeedsSubmit, ' ', r.requestedBy, ' ', r.reviewToken, ' ', r.reviewBlind) info
   from PaperReview r
   where reviewType=?
     and ((reviewSubmitted is null
           and timeApprovalRequested>0))
   group by paperId) as Reviews_ExternalApprovable on (Reviews_ExternalApprovable.paperId=Paper.paperId)
left join PaperConflict as PaperConflict on (PaperConflict.paperId=Paper.paperId
                                             and (PaperConflict.contactId=?))
left join PaperReview as MyReview on (MyReview.paperId=Paper.paperId
                                      and ((MyReview.contactId=?)))
where (coalesce(Reviews_ExternalApprovable.count,0)>0)
  and Paper.timeSubmitted>0
group by Paper.paperId
```
[examples/h0174-hotcrp.md](/examples/h0174-hotcrp.md)