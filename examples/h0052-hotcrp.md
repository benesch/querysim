
## HotCRP Query 0052
```sql
select group_concat(' ', tag, '#', tagIndex
                    order by tag separator '')
from PaperTag
where paperId=?
group by paperId
```
[examples/h0052-hotcrp.md](/examples/h0052-hotcrp.md)