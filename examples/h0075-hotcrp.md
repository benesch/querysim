
## HotCRP Query 0075
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome
from Paper
where (Paper.paperId in (?))
  and Paper.timeSubmitted>0
group by Paper.paperId
```
[examples/h0075-hotcrp.md](/examples/h0075-hotcrp.md)