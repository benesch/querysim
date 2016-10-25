
## HotCRP Query 0047
```sql
select firstName,
       lastName,
       '' affiliation,
          email,
          contactId
from ContactInfo
where contactId in ?
```
[examples/h0047-hotcrp.md](/examples/h0047-hotcrp.md)