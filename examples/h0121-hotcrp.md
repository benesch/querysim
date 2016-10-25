
## HotCRP Query 0121
```sql
select PaperReview.*,
       ContactInfo.firstName,
       ContactInfo.lastName,
       ContactInfo.email,
       ContactInfo.roles as contactRoles,
       ContactInfo.contactTags,
       ReqCI.firstName as reqFirstName,
       ReqCI.lastName as reqLastName,
       ReqCI.email as reqEmail
from PaperReview
join ContactInfo using (contactId)
left join ContactInfo as ReqCI on (ReqCI.contactId=PaperReview.requestedBy)
where PaperReview.paperId=?
  and PaperReview.reviewId=?
group by PaperReview.reviewId
order by PaperReview.paperId,
         reviewOrdinal,
         timeRequested,
         reviewType desc,
         reviewId
```
[examples/h0121-hotcrp.md](/examples/h0121-hotcrp.md)