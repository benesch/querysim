
## HotCRP Query 0094
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
       disabled,

  (select group_concat(paperId)
   from PaperConflict
   where contactId=u.contactId
     and conflictType>=?) paperIds
from ContactInfo u
group by u.contactId
order by lastName,
         firstName,
         email
```
[examples/h0094-hotcrp.md](/examples/h0094-hotcrp.md)