
## HotCRP Query 0044
```sql
select paperId
from PaperReview
where PaperReview.contactId=?
group by paperId
order by paperId
```
[examples/h0044-hotcrp.md](/examples/h0044-hotcrp.md)