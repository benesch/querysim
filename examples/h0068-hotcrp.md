
## HotCRP Query 0068
```sql
select ContactInfo.contactId,
       conflictType,
       email,
       firstName,
       lastName,
       affiliation
from PaperConflict
join ContactInfo using (contactId)
where paperId=?
  and conflictType>=?
```
[examples/h0068-hotcrp.md](/examples/h0068-hotcrp.md)