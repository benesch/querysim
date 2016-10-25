
## HotCRP Query 0113
```sql
select p.paperId,
       pt.paperTags,
       r.reviewType
from Paper p
left join
  (select paperId,
          group_concat(' ', tag, '#', tagIndex
                       order by tag separator '') as paperTags
   from PaperTag
   where tag in ?
   group by paperId) as pt on (pt.paperId=p.paperId)
left join PaperReview r on (r.paperId=p.paperId
                            and r.contactId=?)
left join PaperConflict pc on (pc.paperId=p.paperId
                               and pc.contactId=?)
where p.timeSubmitted>0
  and (pc.conflictType is null
       or p.managerContactId=?)
```
[examples/h0113-hotcrp.md](/examples/h0113-hotcrp.md)