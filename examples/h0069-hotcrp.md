
## HotCRP Query 0069
```sql
select Paper.paperId,
       authorInformation
from Paper
join PaperConflict on (PaperConflict.paperId=Paper.paperId
                       and PaperConflict.contactId=?
                       and PaperConflict.conflictType>=?)
```
[examples/h0069-hotcrp.md](/examples/h0069-hotcrp.md)