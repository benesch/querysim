
## HotCRP Query 0086
```sql
select count(reviewId) num_submitted,
       group_concat(overAllMerit) scores
from ContactInfo
left join PaperReview on (PaperReview.contactId=ContactInfo.contactId
                          and PaperReview.reviewSubmitted is not null)
where (roles&1)!=0
group by ContactInfo.contactId
```
[examples/h0086-hotcrp.md](/examples/h0086-hotcrp.md)