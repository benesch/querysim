**[examples/h0001-hotcrp.md](/examples/h0001-hotcrp.md)**

```sql
select *
from Capability
where salt=?
```
Make a point index on `salt`.

**[examples/h0003-hotcrp.md](/examples/h0003-hotcrp.md)**

```sql
select *
from PaperTagAnno
where tag=?
```

Make a point index on `tag`.

**[examples/h0009-hotcrp.md](/examples/h0009-hotcrp.md)**

```sql
select *
from ContactInfo
where contactId=?
```

**[examples/h0004-hotcrp.md](/examples/h0004-hotcrp.md)**

```sql
select *
from ContactInfo
where email=?
```

**[examples/h0013-hotcrp.md](/examples/h0013-hotcrp.md)

```sql
select contactId
from ContactInfo
where email=?
```

This can be answered using the previous query. (Simple projection.)

**[examples/h0010-hotcrp.md](/examples/h0010-hotcrp.md)**

```sql
select *
from ContactInfo
where contactDbId=?
```

Make separate point indexes on `contactId` (duh), `contactDbId`,
and `email`.

**[examples/h0005-hotcrp.md](/examples/h0005-hotcrp.md)**

```sql
select *
from Mimetype
where mimetype=?
```

Make a point index on `mimetype`.

**[examples/h0006-hotcrp.md](/examples/h0006-hotcrp.md)**

```sql
select value
from Settings
where name=?
```

Make a point index on `name`.

**[examples/h0007-hotcrp.md](/examples/h0007-hotcrp.md)**

```sql
select *
from Formula
order by lower(name)
```

Materialize and make a range index on `lower(name)`.

**[examples/h0014-hotcrp.md](/examples/h0014-hotcrp.md)**

```sql
select paperId
from PaperTag
where tag=? limit 1
```

Make a point index on `tag`.

**[examples/h0015-hotcrp.md](/examples/h0015-hotcrp.md)**

```sql
select paperId
from PaperReview
where reviewId=?
```

(More similar examples 0016–0020.)

**[examples/h0021-hotcrp.md](/examples/h0021-hotcrp.md)**

```sql
select paperId
from Paper
where timeSubmitted>0 limit 1
```

Make an index on `timeSubmitted > 0`.

**[examples/h0038-hotcrp.md](/examples/h0038-hotcrp.md)**

```sql
select paperStorageId
from PaperStorage
where paperId=?
  and documentType=?
  and sha1=?
```

**QUESTION:** Three individual indices or one combined index?
