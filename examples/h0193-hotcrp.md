
## HotCRP Query 0193
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

  (select count(p.paperId)
   from Paper p
   left join PaperConflict c on (c.paperId=p.paperId
                                 and c.contactId=?)
   where leadContactId=u.contactId
     and conflictType is null) numLeads,

  (select count(p.paperId)
   from Paper p
   left join PaperConflict c on (c.paperId=p.paperId
                                 and c.contactId=?)
   where shepherdContactId=u.contactId
     and conflictType is null) numShepherds,
       group_concat(if(r.reviewSubmitted>0,r.overAllMerit,null)) as overAllMerit
from ContactInfo u
left join
  (select r.contactId,
          r.reviewId,
          r.reviewSubmitted,
          r.reviewNeedsSubmit,
          r.overAllMerit,
          count(rating) as numRatings,
          sum(if(rating>0,1,0)) as sumRatings
   from PaperReview r
   join Paper p on (p.paperId=r.paperId)
   left join PaperConflict pc on (pc.paperId=p.paperId
                                  and pc.contactId=?)
   left join ReviewRating rr on (rr.paperId=r.paperId
                                 and rr.reviewId=r.reviewId)
   where (pc.conflictType is null
          or pc.conflictType=0
          or r.contactId=?)
     and (p.timeSubmitted>0
          or r.reviewSubmitted>0)
   group by r.reviewId) as r on (r.contactId=u.contactId)
where u.roles!=0
  and (u.roles&1)!=0
group by u.contactId
order by lastName,
         firstName,
         email
```
[examples/h0193-hotcrp.md](/examples/h0193-hotcrp.md)