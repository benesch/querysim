
## HotCRP Query 0078
```sql
select PaperReview.*,
       ContactInfo.firstName,
       ContactInfo.lastName,
       ContactInfo.email
from PaperReview
join ContactInfo on (ContactInfo.contactId=PaperReview.contactId)
where PaperReview.paperId=?
order by reviewOrdinal
```
[examples/h0078-hotcrp.md](/examples/h0078-hotcrp.md)