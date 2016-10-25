
## HotCRP Query 0059
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
where roles!=0
  and (roles&1)!=0
```
[examples/h0059-hotcrp.md](/examples/h0059-hotcrp.md)