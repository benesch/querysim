
## HotCRP Query 0080
```sql
select PaperComment.*,
       firstName reviewFirstName,
       lastName reviewLastName,
       email reviewEmail
from PaperComment
join ContactInfo on (ContactInfo.contactId=PaperComment.contactId)
where PaperComment.paperId=?
order by commentId
```
[examples/h0080-hotcrp.md](/examples/h0080-hotcrp.md)