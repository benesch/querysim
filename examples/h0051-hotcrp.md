
## HotCRP Query 0051
```sql
select topicId,
       if(interest>0,1,0),
       count(*)
from TopicInterest
where interest!=0
group by topicId,
         interest>0
```
[examples/h0051-hotcrp.md](/examples/h0051-hotcrp.md)