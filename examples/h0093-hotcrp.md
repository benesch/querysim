
## HotCRP Query 0093
```sql
select name,
       ReviewRequest.email,
       firstName as reqFirstName,
       lastName as reqLastName,
       ContactInfo.email as reqEmail,
       requestedBy,
       reason,
       reviewRound
from ReviewRequest
join ContactInfo on (ContactInfo.contactId=ReviewRequest.requestedBy)
where ReviewRequest.paperId=?
  and requestedBy=?
```
[examples/h0093-hotcrp.md](/examples/h0093-hotcrp.md)