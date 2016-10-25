
## HotCRP Query 0181
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome,
       Reviews_1.info Reviews_1_info,
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
   where r.contactId=?
   group by paperId) as Reviews_1 on (Reviews_1.paperId=Paper.paperId)
left join PaperConflict as PaperConflict on (PaperConflict.paperId=Paper.paperId
                                             and (PaperConflict.contactId=?))
left join PaperReview as MyReview on (MyReview.paperId=Paper.paperId
                                      and ((MyReview.contactId=?)))
where (coalesce(Reviews_1.count,0)>0)
  and (PaperConflict.conflictType>=?
       or (Paper.timeWithdrawn<=0
           and MyReview.reviewType is not null))
group by Paper.paperId
```
[examples/h0181-hotcrp.md](/examples/h0181-hotcrp.md)