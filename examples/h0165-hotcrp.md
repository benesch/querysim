
## HotCRP Query 0165
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

  (select group_concat(topicId, ' ', interest)
   from TopicInterest
   where contactId=u.contactId) topicInterest,
       count(if(r.reviewNeedsSubmit<=0,r.reviewSubmitted,r.reviewId)) as numReviews,
       count(r.reviewSubmitted) as numReviewsSubmitted,
       sum(r.numRatings) as numRatings,
       sum(r.sumRatings) as sumRatings,

  (select count(paperId)
   from Paper
   where leadContactId=u.contactId) numLeads,

  (select count(paperId)
   from Paper
   where shepherdContactId=u.contactId) numShepherds,
       group_concat(if(r.reviewSubmitted>0,r.overAllMerit,null)) as overAllMerit
from ContactInfo u
left join
  (select r.*,
          count(rating) as numRatings,
          sum(if(rating>0,1,0)) as sumRatings
   from PaperReview r
   join Paper p on (p.paperId=r.paperId)
   left join ReviewRating rr on (rr.reviewId=r.reviewId)
   where (p.timeSubmitted>0
          or r.reviewSubmitted>0)
   group by r.reviewId) as r on (r.contactId=u.contactId)
where u.roles!=0
  and (u.roles&1)!=0
group by u.contactId
order by lastName,
         firstName,
         email
```
[examples/h0165-hotcrp.md](/examples/h0165-hotcrp.md)