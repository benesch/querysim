
## HotCRP Query 0116
```sql
select conflictType as conflict_type,
       reviewType as review_type,
       reviewSubmitted as review_submitted,
       reviewNeedsSubmit as review_needs_submit,
       PaperReview.contactId as review_token_cid,
       ContactInfo.contactId
from
  (select ? paperId) P
join ContactInfo
left join PaperReview on (PaperReview.paperId=?
                          and PaperReview.contactId=ContactInfo.contactId)
left join PaperConflict on (PaperConflict.paperId=?
                            and PaperConflict.contactId=ContactInfo.contactId)
where roles!=0
  and (roles&1)!=0
```
[examples/h0116-hotcrp.md](/examples/h0116-hotcrp.md)