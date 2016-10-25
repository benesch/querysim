
## HotCRP Query 0050
```sql
select firstName,
       lastName,
       unaccentedName,
       email,
       contactId,
       roles
from ContactInfo
where email like ?
```
[examples/h0050-hotcrp.md](/examples/h0050-hotcrp.md)