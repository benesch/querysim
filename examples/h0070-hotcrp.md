
## HotCRP Query 0070
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
where paperStorageId in ?
```
[examples/h0070-hotcrp.md](/examples/h0070-hotcrp.md)