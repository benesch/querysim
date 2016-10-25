
## HotCRP Query 0107
```sql
select conflictType as conflict_type,
       reviewType as review_type,
       reviewSubmitted as review_submitted,
       reviewNeedsSubmit as review_needs_submit,
       PaperReview.contactId as review_token_cid,
       ? contactId
from
  (select 1 paperId) P
left join PaperReview on (PaperReview.paperId=P.paperId
                          and (PaperReview.contactId=?))
left join PaperConflict on (PaperConflict.paperId=?
                            and PaperConflict.contactId=?)
```
[examples/h0107-hotcrp.md](/examples/h0107-hotcrp.md)