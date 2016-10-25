
## HotCRP Query 0063
```sql
select min(Paper.paperId)
from Paper
join ContactInfo on (ContactInfo.paperId=Paper.paperId
                     and ContactInfo.contactId=?
                     and ContactInfo.conflictType>=?)
```
[examples/h0063-hotcrp.md](/examples/h0063-hotcrp.md)