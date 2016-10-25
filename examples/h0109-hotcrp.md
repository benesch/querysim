
## HotCRP Query 0109
```sql
select PRP.paperId,
       PRP.contactId,
       PRP.preference
from PaperReviewPreference PRP
join ContactInfo c on (c.contactId=PRP.contactId
                       and c.roles!=0
                       and (c.roles&1)!=0)
join Paper P on (P.paperId=PRP.paperId)
left join PaperConflict PC on (PC.paperId=PRP.paperId
                               and PC.contactId=PRP.contactId)
where PRP.preference<=?
  and coalesce(PC.conflictType,0)<=0
  and P.timeWithdrawn<=0
  and P.timeSubmitted>0 limit 1
```
[examples/h0109-hotcrp.md](/examples/h0109-hotcrp.md)