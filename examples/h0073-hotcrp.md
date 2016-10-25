
## HotCRP Query 0073
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome
from Paper
where true
  and Paper.timeSubmitted>0
group by Paper.paperId
```
[examples/h0073-hotcrp.md](/examples/h0073-hotcrp.md)