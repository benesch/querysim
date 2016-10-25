
## HotCRP Query 0021
```sql
select paperId
from Paper
where timeSubmitted>0 limit 1
```
[examples/h0021-hotcrp.md](/examples/h0021-hotcrp.md)


## HotCRP Query 0026
```sql
select min(Paper.paperId)
from Paper
where timeSubmitted>0
```
[examples/h0026-hotcrp.md](/examples/h0026-hotcrp.md)


## HotCRP Query 0034
```sql
select outcome,
       count(*)
from Paper
where timeSubmitted>0
group by outcome
```
[examples/h0034-hotcrp.md](/examples/h0034-hotcrp.md)


## HotCRP Query 0037
```sql
select outcome,
       count(paperId)
from Paper
where timeSubmitted>0
group by outcome
```
[examples/h0037-hotcrp.md](/examples/h0037-hotcrp.md)


## HotCRP Query 0045
```sql
select distinct tag
from PaperTag t
join Paper p on (p.paperId=t.paperId)
where p.timeSubmitted>0
```
[examples/h0045-hotcrp.md](/examples/h0045-hotcrp.md)


## HotCRP Query 0055
```sql
select outcome,
       count(paperId)
from Paper
where timeSubmitted>0
  or (timeSubmitted=?
      and timeWithdrawn>=?)
group by outcome
```
[examples/h0055-hotcrp.md](/examples/h0055-hotcrp.md)


## HotCRP Query 0065
```sql
select r.reviewId
from PaperReview r
join Paper p on (p.paperId=r.paperId
                 and p.timeSubmitted>0)
where (r.contactId=?)
  and r.reviewNeedsSubmit!=0 limit 1
```
[examples/h0065-hotcrp.md](/examples/h0065-hotcrp.md)


## HotCRP Query 0066
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome
from Paper
where true
group by Paper.paperId
```
[examples/h0066-hotcrp.md](/examples/h0066-hotcrp.md)


## HotCRP Query 0073
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome
from Paper
where true
  and Paper.timeSubmitted>0
group by Paper.paperId
```
[examples/h0073-hotcrp.md](/examples/h0073-hotcrp.md)

## HotCRP Query 0075
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome
from Paper
where (Paper.paperId in (?))
  and Paper.timeSubmitted>0
group by Paper.paperId
```
[examples/h0075-hotcrp.md](/examples/h0075-hotcrp.md)


## HotCRP Query 0076
```sql
select Paper.paperId paperId,
       Paper.timeSubmitted timeSubmitted,
       Paper.timeWithdrawn timeWithdrawn,
       Paper.outcome outcome
from Paper
where (Paper.outcome in (?))
  and Paper.timeSubmitted>0
group by Paper.paperId
```
[examples/h0076-hotcrp.md](/examples/h0076-hotcrp.md)


## HotCRP Query 0079
```sql
select distinct tag
from PaperTag t
join Paper p on (p.paperId=t.paperId)
left join PaperConflict pc on (pc.paperId=t.paperId
                               and pc.contactId=?)
where p.timeSubmitted>0
  and (p.managerContactId=?
       or pc.conflictType is null)
```
[examples/h0079-hotcrp.md](/examples/h0079-hotcrp.md)


## HotCRP Query 0085
```sql
select distinct tag
from PaperTag t
join Paper p on (p.paperId=t.paperId)
left join PaperConflict pc on (pc.paperId=t.paperId
                               and pc.contactId=?)
where p.timeSubmitted>0
  and (p.managerContactId=0
       or p.managerContactId=?
       or pc.conflictType is null)
```
[examples/h0085-hotcrp.md](/examples/h0085-hotcrp.md)

