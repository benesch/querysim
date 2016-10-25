
## HotCRP Query 0037
```sql
select outcome,
       count(paperId)
from Paper
where timeSubmitted>0
group by outcome
```
[examples/h0037-hotcrp.md](/examples/h0037-hotcrp.md)