
## HotCRP Query 0056
```sql
select firstName,
       lastName,
       affiliation,
       email,
       contactId,
       roles,
       contactTags,
       disabled
from ContactInfo
where (roles&1)!=0
```
[examples/h0056-hotcrp.md](/examples/h0056-hotcrp.md)