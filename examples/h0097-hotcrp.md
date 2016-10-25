
## HotCRP Query 0097
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome,
       PaperConflict.conflictType conflictType
from Paper
left join PaperConflict as PaperConflict on (PaperConflict.paperId=Paper.paperId
                                             and (PaperConflict.contactId=0))
where true
  and PaperConflict.conflictType>=?
group by Paper.paperId
```
[examples/h0097-hotcrp.md](/examples/h0097-hotcrp.md)