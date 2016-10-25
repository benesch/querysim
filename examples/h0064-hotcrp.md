
## HotCRP Query 0064
```sql
select min(Paper.paperId)
from Paper
join ContactInfo on (ContactInfo.paperId=Paper.paperId
                     and ContactInfo.contactId=0
                     and ContactInfo.conflictType>=?)
```
[examples/h0064-hotcrp.md](/examples/h0064-hotcrp.md)