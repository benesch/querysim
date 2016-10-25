
## HotCRP Query 0100
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome,
       PaperConflict.conflictType conflictType
from Paper
left join PaperConflict as PaperConflict on (PaperConflict.paperId=Paper.paperId
                                             and (PaperConflict.contactId=?))
where true
  and (PaperConflict.conflictType>=?
       or Paper.paperId=?)
group by Paper.paperId
```
[examples/h0100-hotcrp.md](/examples/h0100-hotcrp.md)