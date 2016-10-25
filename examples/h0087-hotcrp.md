
## HotCRP Query 0087
```sql
select ContactInfo.contactId,
       firstName,
       lastName,
       email,
       preferredEmail,
       password,
       roles,
       disabled,
       contactTags,
       conflictType,
       0 myReviewType
from ContactInfo
join PaperConflict using (contactId)
where paperId=?
  and conflictType>=?
group by ContactInfo.contactId
```
[examples/h0087-hotcrp.md](/examples/h0087-hotcrp.md)