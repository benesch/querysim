
## HotCRP Query 0074
```sql
select paperStorageId,
       paperId,
       timestamp,
       mimetype,
       mimetypeid,
       sha1,
       documentType,
       filename,
       infoJson,
       size,
       filterType,
       originalStorageId
from PaperStorage
where paperId=?
  and paperStorageId in ?
```
[examples/h0074-hotcrp.md](/examples/h0074-hotcrp.md)