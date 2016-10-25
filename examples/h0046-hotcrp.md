
## HotCRP Query 0046
```sql
select paperId
from PaperComment
where PaperComment.contactId=?
group by paperId
order by paperId
```
[examples/h0046-hotcrp.md](/examples/h0046-hotcrp.md)