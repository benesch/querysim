
## HotCRP Query 0076
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome
from Paper
where (Paper.outcome in (?))
  and Paper.timeSubmitted>0
group by Paper.paperId
```
[examples/h0076-hotcrp.md](/examples/h0076-hotcrp.md)