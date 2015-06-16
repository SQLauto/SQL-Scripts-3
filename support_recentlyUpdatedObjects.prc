-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT  
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'dbo'
     AND SPECIFIC_NAME = N'support_recentlyUpdated' 
)
   DROP PROCEDURE dbo.support_recentlyUpdated
GO

CREATE PROCEDURE dbo.support_recentlyUpdated
	@daysBack int = 90
AS
	SELECT name, create_date, modify_date
	FROM sys.objects
	WHERE type = 'p'
	and datediff(d, modify_date, getdate()) < @daysBack
	order by 2 desc
GO

EXECUTE dbo.support_recentlyUpdated @daysBack=90
GO
