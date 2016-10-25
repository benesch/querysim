
## HotCRP Query 0041
```sql
select contactId,
       topicId,
       interest
from TopicInterest
where interest!=0
order by contactId
```
[examples/h0041-hotcrp.md](/examples/h0041-hotcrp.md)