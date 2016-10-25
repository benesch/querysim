
## HotCRP Query 0032
```sql
select reviewRound,
       count(*)
from PaperReview
group by reviewRound
```
[examples/h0032-hotcrp.md](/examples/h0032-hotcrp.md)