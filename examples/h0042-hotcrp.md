
## HotCRP Query 0042
```sql
select topicId,
       interest
from TopicArea
join TopicInterest using (topicId)
where contactId=?
```
[examples/h0042-hotcrp.md](/examples/h0042-hotcrp.md)