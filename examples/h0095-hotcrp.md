
## HotCRP Query 0095
```sql
select Paper.paperId,
       reviewId,
       reviewType,
       reviewSubmitted,
       reviewModified,
       timeApprovalRequested,
       reviewNeedsSubmit,
       reviewRound,
       reviewOrdinal,
       timeRequested,
       PaperReview.contactId,
       lastName,
       firstName,
       email
from Paper
join PaperReview using (paperId)
join ContactInfo on (PaperReview.contactId=ContactInfo.contactId)
where paperId in ?
```
[examples/h0095-hotcrp.md](/examples/h0095-hotcrp.md)