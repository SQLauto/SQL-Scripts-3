declare @searchString varchar(100)
Set @searchString = '%rollupacctid%'

SELECT Distinct SO.Name
FROM sysobjects SO (NOLOCK) 
INNER JOIN syscomments SC (NOLOCK)
on SO.Id = SC.ID AND SO.Type = 'P'
AND SC.Text LIKE @searchString
ORDER BY SO.Name