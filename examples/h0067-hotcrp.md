
## HotCRP Query 0067
```sql
select PaperStorage.*
from FilteredDocument
join PaperStorage on (PaperStorage.paperStorageId=FilteredDocument.outDocId)
where inDocId=?
  and FilteredDocument.filterType=?
```
[examples/h0067-hotcrp.md](/examples/h0067-hotcrp.md)