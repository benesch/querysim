## Topic interest thoughts

### Indices

**[examples/h0018-hotcrp.md](/examples/h0018-hotcrp.md)**

```sql
select contactId,
       topicId,
       interest
from TopicInterest
```

**[examples/h0030-hotcrp.md](/examples/h0030-hotcrp.md)**

```sql
select topicId,
       interest
from TopicInterest
where contactId=?
```

**[examples/h0035-hotcrp.md](/examples/h0035-hotcrp.md)**

```sql
select topicId,
       interest
from TopicInterest
where contactId=?
  and interest!=0
```

Clearly need an index on `contactId`. **QUESTION:** another index
on `interest != 0`, or a joint index on `interest != 0, contactId`?
Consider also the example below.

**[examples/h0041-hotcrp.md](/examples/h0041-hotcrp.md)**

```sql
select contactId,
       topicId,
       interest
from TopicInterest
where interest!=0
order by contactId
```

**[examples/h0025-hotcrp.md](/examples/h0025-hotcrp.md)**

```sql
select count(topicId)
from TopicInterest
where contactId=?
```

This comes up frequently enough that it's worth suggesting the following
query for materialization:

```sql
select count(topicId)
from TopicInterest
group by contactId
```

**[examples/h0058-hotcrp.md](/examples/h0058-hotcrp.md)**

```sql
select count(ta.topicId),
       count(ti.topicId)
from TopicArea ta
left join TopicInterest ti on (ti.contactId=?
                               and ti.topicId=ta.topicId)
```

We want to rewrite this to

```sql
select count(ta.topicId),
       interestedCount
from TopicArea ta
left join (
  select count(topicId) as interestedCount
  from TopicInterest
  group by contactId
) ti on (ti.contactId=? and ti.topicId=ta.topicId)
```

and preferring to push down groupings should get us there!

**[examples/h0042-hotcrp.md](/examples/h0042-hotcrp.md)**

```sql
select topicId,
       interest
from TopicArea
join TopicInterest using (topicId)
where contactId=?
```

**[examples/h0051-hotcrp.md](/examples/h0051-hotcrp.md)**

```sql
select topicId,
       if(interest>0,1,0),
       count(*)
from TopicInterest
where interest!=0
group by topicId,
         interest>0
```

?!?!

## Embedded in massive joins

[examples/h0150-hotcrp.md](/examples/h0150-hotcrp.md)  
[examples/h0165-hotcrp.md](/examples/h0165-hotcrp.md)  
[examples/h0167-hotcrp.md](/examples/h0167-hotcrp.md)  
[examples/h0173-hotcrp.md](/examples/h0173-hotcrp.md)  
[examples/h0177-hotcrp.md](/examples/h0177-hotcrp.md)  
[examples/h0179-hotcrp.md](/examples/h0179-hotcrp.md)  
[examples/h0182-hotcrp.md](/examples/h0182-hotcrp.md)  
[examples/h0186-hotcrp.md](/examples/h0186-hotcrp.md)  
[examples/h0192-hotcrp.md](/examples/h0192-hotcrp.md)  
[examples/h0193-hotcrp.md](/examples/h0193-hotcrp.md)

```sql
select group_concat(topicId, ' ', interest)
   from TopicInterest
   where contactId=u.contactId
```
