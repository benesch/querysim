
## HotCRP Query 0112
```sql
select any_newpcrev,
       any_lead,
       any_shepherd
from
  (select PaperReview.paperId any_newpcrev
   from PaperReview
   where reviewType>=?
     and reviewSubmitted is null
     and reviewNeedsSubmit!=0
     and timeRequested>timeRequestNotified limit 1) a
left join
  (select paperId any_lead
   from Paper
   where timeSubmitted>0
     and leadContactId!=0 limit 1) b on (true)
left join
  (select paperId any_shepherd
   from Paper
   where timeSubmitted>0
     and shepherdContactId!=0 limit 1) c on (true)
```
[examples/h0112-hotcrp.md](/examples/h0112-hotcrp.md)