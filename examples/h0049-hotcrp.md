
## HotCRP Query 0049
```sql
select contactId
from ContactInfo
where roles!=0
  and (roles&1)!=0
order by lastName,
         firstName,
         email
```
[examples/h0049-hotcrp.md](/examples/h0049-hotcrp.md)