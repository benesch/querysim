
## HotCRP Query 0119
```sql
select ContactInfo.contactId,
       reviewType,
       commentId,
       conflictType,
       watch
from ContactInfo
left join PaperReview on (PaperReview.paperId=?
                          and PaperReview.contactId=ContactInfo.contactId)
left join PaperComment on (PaperComment.paperId=?
                           and PaperComment.contactId=ContactInfo.contactId)
left join PaperConflict on (PaperConflict.paperId=?
                            and PaperConflict.contactId=ContactInfo.contactId)
left join PaperWatch on (PaperWatch.paperId=?
                         and PaperWatch.contactId=ContactInfo.contactId)
where ContactInfo.contactId=?
```
[examples/h0119-hotcrp.md](/examples/h0119-hotcrp.md)