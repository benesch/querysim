
## HotCRP Query 0053
```sql
select paperStorageId,
       sha1,
       timestamp,
       size,
       mimetype
from PaperStorage
where paperId=?
  and documentType=?
  and sha1=?
```
[examples/h0053-hotcrp.md](/examples/h0053-hotcrp.md)