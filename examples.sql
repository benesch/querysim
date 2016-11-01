--
-- Article with votes
--

-- Input

Article(id, user, title, body, ts).
Vote(id, user, ts).

ArticlesWithVotes = SELECT * FROM Article LEFT JOIN (
    SELECT COUNT(user) FROM Vote GROUP BY user
  ) as VoteCount ON Article.id = Vote.id
  WHERE id = ?

NewArticlesWithVotes = SELECT * FROM Article LEFT JOIN (
    SELECT COUNT(user) as votes FROM Vote GROUP BY user
  ) as VoteCount ON Article.id = Vote.id
  WHERE ts < ?
--  ORDER BY votes DESC
--  LIMIT 20

VotesOnArticle = SELECT COUNT(user) FROM Vote WHERE id = ?

UserHasVoted = SELECT * FROM Vote WHERE id = ? AND user = ?

-- Output

-- N1 = Base("Vote")
-- N2 = Base("Article")
-- N3 = Aggregate(COUNT, GROUP BY id, N2)
-- N4 = Join(Article.id = Vote.id, N2, N3)

-- ArticlesWithVotes = N4
-- NewArticlesWithVotes = N4
-- VotesOnArticle = N3
-- UserHasVoted = N1


--
-- HotCRP
--

select PaperComment.*,
       firstName reviewFirstName,
       lastName reviewLastName,
       email reviewEmail
from PaperComment
join ContactInfo on (ContactInfo.contactId=PaperComment.contactId)
where PaperComment.paperId=?

select paperId
from PaperComment
where PaperComment.contactId=?
group by paperId


select PaperComment.*,
       firstName reviewFirstName,
       lastName reviewLastName,
       email reviewEmail
from PaperComment
join ContactInfo on (ContactInfo.contactId=PaperComment.contactId)
where commentId=?
