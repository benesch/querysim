
## HotCRP Query 0045
```sql
select distinct tag
from PaperTag t
join Paper p on (p.paperId=t.paperId)
where p.timeSubmitted>0
```
[examples/h0045-hotcrp.md](/examples/h0045-hotcrp.md)