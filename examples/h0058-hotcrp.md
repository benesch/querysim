
## HotCRP Query 0058
```sql
select count(ta.topicId),
       count(ti.topicId)
from TopicArea ta
left join TopicInterest ti on (ti.contactId=?
                               and ti.topicId=ta.topicId)
```
[examples/h0058-hotcrp.md](/examples/h0058-hotcrp.md)