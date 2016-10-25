
## HotCRP Query 0054
```sql
select ContactInfo.contactId,
       conflictType,
       email
from PaperConflict
join ContactInfo using (contactId)
where paperId=?
```
[examples/h0054-hotcrp.md](/examples/h0054-hotcrp.md)