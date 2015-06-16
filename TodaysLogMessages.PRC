

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'TodaysLogMessages' 
	   AND 	  type = 'P')
    DROP PROCEDURE TodaysLogMessages
GO

CREATE PROCEDURE TodaysLogMessages 
AS
	select sltimestamp, logmessage
	from syncsystemlog
	where datediff(d, sltimestamp, getdate()) = 0
	order by sltimestamp desc
GO

EXECUTE TodaysLogMessages 
GO

