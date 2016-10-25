
## HotCRP Query 0185
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
   left join
     (select reviewId,
             count(rating) as nrate_good
      from ReviewRating
      where rating>0
      group by reviewId) as Ratings_good on (Ratings_good.reviewId=r.reviewId)
   where nrate_good>0
     and r.contactId=?
   group by paperId) as Reviews_1 on (Reviews_1.paperId=Paper.paperId)
left join PaperConflict as PaperConflict on (PaperConflict.paperId=Paper.paperId
                                             and (PaperConflict.contactId=?))
left join PaperReview as MyReview on (MyReview.paperId=Paper.paperId
                                      and ((MyReview.contactId=?)))
where ((coalesce(Reviews_1.count,0)>0))
  and Paper.timeSubmitted>0
group by Paper.paperId
```
[examples/h0185-hotcrp.md](/examples/h0185-hotcrp.md)