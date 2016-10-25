
## HotCRP Query 0034
```sql
select outcome,
       count(*)
from Paper
where timeSubmitted>0
group by outcome
```
[examples/h0034-hotcrp.md](/examples/h0034-hotcrp.md)