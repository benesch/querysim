
## HotCRP Query 0082
```sql
select ContactInfo.contactId,
       count(reviewId)
from ContactInfo
left join PaperReview on (PaperReview.contactId=ContactInfo.contactId
                          and PaperReview.reviewType>=?)
where roles!=0
  and (roles&1)!=0
group by ContactInfo.contactId
```
[examples/h0082-hotcrp.md](/examples/h0082-hotcrp.md)