
## HotCRP Query 0183
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome,
       Paper.managerContactId managerContactId,
       Paper.leadContactId leadContactId,
       count(Tag_1.tag) Tag_1_ct,
       Reviews_All.info Reviews_All_info,
       PaperConflict.conflictType conflictType,
       MyReview.reviewType myReviewType,
       MyReview.reviewNeedsSubmit myReviewNeedsSubmit,
       MyReview.reviewSubmitted myReviewSubmitted,

  (select group_concat(' ', tag, '#', tagIndex separator '')
   from PaperTag
   where PaperTag.paperId=Paper.paperId) paperTags
from Paper
left join PaperTag as Tag_1 on (Tag_1.paperId=Paper.paperId
                                and (Tag_1.tag=?))
left join
  (select r.paperId,
          count(r.reviewId) count,
                            group_concat(r.reviewId, ' ', r.contactId, ' ', r.reviewType, ' ', coalesce(r.reviewSubmitted,0), ' ', r.reviewNeedsSubmit, ' ', r.requestedBy, ' ', r.reviewToken, ' ', r.reviewBlind) info
   from PaperReview r
   group by paperId) as Reviews_All on (Reviews_All.paperId=Paper.paperId)
left join PaperConflict as PaperConflict on (PaperConflict.paperId=Paper.paperId
                                             and (PaperConflict.contactId=?))
left join PaperReview as MyReview on (MyReview.paperId=Paper.paperId
                                      and ((MyReview.contactId=?)))
where ((Tag_1.tag is not null)
       and (coalesce(Reviews_All.count,0)>=?))
  and Paper.timeSubmitted>0
group by Paper.paperId
```
[examples/h0183-hotcrp.md](/examples/h0183-hotcrp.md)