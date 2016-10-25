
## HotCRP Query 0048
```sql
select contactId,
       count(preference)
from PaperReviewPreference
where preference!=0
group by contactId
```
[examples/h0048-hotcrp.md](/examples/h0048-hotcrp.md)