
## HotCRP Query 0089
```sql
select count(reviewId) num_submitted,
       group_concat(overAllMerit) scores
from ContactInfo
left join PaperReview on (PaperReview.contactId=ContactInfo.contactId
                          and PaperReview.reviewSubmitted is not null)
where roles!=0
  and (roles&1)!=0
group by ContactInfo.contactId
```
[examples/h0089-hotcrp.md](/examples/h0089-hotcrp.md)