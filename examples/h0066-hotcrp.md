
## HotCRP Query 0066
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome
from Paper
where true
group by Paper.paperId
```
[examples/h0066-hotcrp.md](/examples/h0066-hotcrp.md)