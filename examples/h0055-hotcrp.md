
## HotCRP Query 0055
```sql
select outcome,
       count(paperId)
from Paper
where timeSubmitted>0
  or (timeSubmitted=?
      and timeWithdrawn>=?)
group by outcome
```
[examples/h0055-hotcrp.md](/examples/h0055-hotcrp.md)