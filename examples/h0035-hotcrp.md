
## HotCRP Query 0035
```sql
select topicId,
       interest
from TopicInterest
where contactId=?
  and interest!=0
```
[examples/h0035-hotcrp.md](/examples/h0035-hotcrp.md)