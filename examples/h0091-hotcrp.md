
## HotCRP Query 0091
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
```
[examples/h0091-hotcrp.md](/examples/h0091-hotcrp.md)