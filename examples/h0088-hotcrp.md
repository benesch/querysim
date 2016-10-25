
## HotCRP Query 0088
```sql
select Paper.paperId,
       count(pc.contactId)
from Paper
join PaperConflict c on (c.paperId=Paper.paperId
                         and c.contactId=?
                         and c.conflictType>=?)
join PaperConflict pc on (pc.paperId=Paper.paperId
                          and pc.conflictType>=?)
group by Paper.paperId
order by Paper.paperId
```
[examples/h0088-hotcrp.md](/examples/h0088-hotcrp.md)