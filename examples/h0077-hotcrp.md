
## HotCRP Query 0077
```sql
select PaperComment.*,
       firstName reviewFirstName,
       lastName reviewLastName,
       email reviewEmail
from PaperComment
join ContactInfo on (ContactInfo.contactId=PaperComment.contactId)
where commentId=?
order by commentId
```
[examples/h0077-hotcrp.md](/examples/h0077-hotcrp.md)