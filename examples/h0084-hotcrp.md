
## HotCRP Query 0084
```sql
select u.contactId,
       firstName,
       lastName,
       email,
       affiliation,
       roles,
       contactTags,
       voicePhoneNumber,
       u.collaborators,
       lastLogin,
       disabled
from ContactInfo u
where u.roles!=0
  and (u.roles&1)!=0
group by u.contactId
order by lastName,
         firstName,
         email
```
[examples/h0084-hotcrp.md](/examples/h0084-hotcrp.md)