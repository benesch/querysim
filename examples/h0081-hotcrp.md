
## HotCRP Query 0081
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
order by lastName,
         firstName,
         email
```
[examples/h0081-hotcrp.md](/examples/h0081-hotcrp.md)