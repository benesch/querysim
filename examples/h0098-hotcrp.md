
## HotCRP Query 0098
```sql
select ContactInfo.contactId,
       PaperConflict.conflictType,
       reviewType,
       reviewModified,
       reviewId
from ContactInfo
left join PaperConflict on (PaperConflict.contactId=ContactInfo.contactId
                            and PaperConflict.paperId=?)
left join PaperReview on (PaperReview.contactId=ContactInfo.contactId
                          and PaperReview.paperId=?)
where ContactInfo.roles!=0
  and (ContactInfo.roles&1)!=0
```
[examples/h0098-hotcrp.md](/examples/h0098-hotcrp.md)