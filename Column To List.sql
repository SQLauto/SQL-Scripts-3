
declare @listStr varchar(max)
select @listStr = COALESCE(@listStr+',' ,'') + 'PubShortName='+PubShortName
from nsPublications p
where p.PubFrequency & @frequency > 0	
