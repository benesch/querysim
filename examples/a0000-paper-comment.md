## PaperComment thoughts

**[examples/h0046-hotcrp.md](/examples/h0046-hotcrp.md)**
```sql
select paperId
from PaperComment
where PaperComment.contactId=?
group by paperId
order by paperId
```

This is really a `SELECT DISTINCT`; could be (easily?) derived from the
following query.

**[examples/h0077-hotcrp.md](/examples/h0077-hotcrp.md)**

```sql
select PaperComment.*,
       firstName reviewFirstName,
       lastName reviewLastName,
       email reviewEmail
from PaperComment
join ContactInfo on (ContactInfo.contactId=PaperComment.contactId)
where commentId=?
order by commentId
```

**[examples/h0080-hotcrp.md](/examples/h0080-hotcrp.md)**

```sql
select PaperComment.*,
       firstName reviewFirstName,
       lastName reviewLastName,
       email reviewEmail
from PaperComment
join ContactInfo on (ContactInfo.contactId=PaperComment.contactId)
where PaperComment.paperId=?
order by commentId
```

The previous two queries are identical except for a parameterized select
that will fall on the very outside of the query. Simple rule: build
index on any such column compared to a parameter.

**[examples/h0119-hotcrp.md](/examples/h0119-hotcrp.md)**

```sql
select ContactInfo.contactId,
       reviewType,
       commentId,
       conflictType,
       watch
from ContactInfo
left join PaperReview on (PaperReview.paperId=?
                          and PaperReview.contactId=ContactInfo.contactId)
left join PaperComment on (PaperComment.paperId=?
                           and PaperComment.contactId=ContactInfo.contactId)
left join PaperConflict on (PaperConflict.paperId=?
                            and PaperConflict.contactId=ContactInfo.contactId)
left join PaperWatch on (PaperWatch.paperId=?
                         and PaperWatch.contactId=ContactInfo.contactId)
where ContactInfo.contactId=?
```

ALL of the following queries can be answered with this one.

**[examples/h0140-hotcrp.md](/examples/h0140-hotcrp.md)**

```sql
select ContactInfo.contactId,
       firstName,
       lastName,
       email,
       password,
       contactTags,
       roles,
       defaultWatch,
       PaperReview.reviewType myReviewType,
       PaperReview.reviewSubmitted myReviewSubmitted,
       PaperReview.reviewNeedsSubmit myReviewNeedsSubmit,
       conflictType,
       watch,
       preferredEmail,
       disabled
from ContactInfo
left join PaperConflict on (PaperConflict.paperId=?
                            and PaperConflict.contactId=ContactInfo.contactId)
left join PaperWatch on (PaperWatch.paperId=?
                         and PaperWatch.contactId=ContactInfo.contactId)
left join PaperReview on (PaperReview.paperId=?
                          and PaperReview.contactId=ContactInfo.contactId)
left join PaperComment on (PaperComment.paperId=?
                           and PaperComment.contactId=ContactInfo.contactId)
where watch is not null
  or conflictType>=?
  or reviewType is not null
  or commentId is not null
  or (defaultWatch & ?)!=0
order by conflictType
```

Identical to previous modulo obnoxious selection.
