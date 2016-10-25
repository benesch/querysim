
## HotCRP Query 0083
```sql
select ContactInfo.contactDbId,
       Conferences.confid,
       roles,
       password
from ContactInfo
left join Conferences on (Conferences.`dbname`=?)
left join Roles on (Roles.contactDbId=ContactInfo.contactDbId
                    and Roles.confid=Conferences.confid)
where email=?
```
[examples/h0083-hotcrp.md](/examples/h0083-hotcrp.md)