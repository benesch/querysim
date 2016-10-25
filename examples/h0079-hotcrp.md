
## HotCRP Query 0079
```sql
select distinct tag
from PaperTag t
join Paper p on (p.paperId=t.paperId)
left join PaperConflict pc on (pc.paperId=t.paperId
                               and pc.contactId=?)
where p.timeSubmitted>0
  and (p.managerContactId=?
       or pc.conflictType is null)
```
[examples/h0079-hotcrp.md](/examples/h0079-hotcrp.md)