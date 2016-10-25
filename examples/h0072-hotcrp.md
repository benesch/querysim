
## HotCRP Query 0072
```sql
select rating,
       count(PaperReview.reviewId)
from PaperReview
join ReviewRating on (PaperReview.contactId=?
                      and PaperReview.reviewId=ReviewRating.reviewId)
group by rating
order by rating desc
```
[examples/h0072-hotcrp.md](/examples/h0072-hotcrp.md)