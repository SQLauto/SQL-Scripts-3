IF EXISTS (
  SELECT  1
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'dbo'
     AND SPECIFIC_NAME = N'support_recentlyModifiedObjects' 
)
   DROP PROCEDURE dbo.support_recentlyModifiedObjects
GO

CREATE PROCEDURE dbo.support_recentlyModifiedObjects
	@daysBack int = 90
AS
	SELECT name, create_date, modify_date, 'Procedure' as [type]
	FROM sys.objects
	WHERE type = 'p'
	and datediff(d, modify_date, getdate()) < @daysBack
	union all
	SELECT name, create_date, modify_date, 'Table' as [type]
	FROM sys.objects
	WHERE type = 'U'
	and datediff(d, modify_date, getdate()) < @daysBack
	
	order by 2 desc

GO

EXECUTE dbo.support_recentlyModifiedObjects @daysBack=90
GO
