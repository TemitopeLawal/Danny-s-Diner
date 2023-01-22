Use Accenture
go

Select Reactions.ContentID, Reactions.ReactionType, Reactions.Datetime, Content.ContentType, 
Content.Category, ReactionTypes.Sentiment, ReactionTypes.Score
From Reactions, Content, ReactionTypes
Where Reactions.ContentID=Content.ContentID
AND Reactions.ReactionType=ReactionTypes.ReactionType;

Select Top 5 Content.Category, Sum(ReactionTypes.Score) as TotalScore
From Reactions, Content, ReactionTypes
Where Reactions.ContentID=Content.ContentID
AND Reactions.ReactionType=ReactionTypes.ReactionType
Group by Content.Category
Order by Sum(ReactionTypes.Score) DESC; 