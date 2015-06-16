IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_NextDate]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[support_NextDate]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE FUNCTION [dbo].[support_NextDate] (
	@dayofweek nvarchar(9)
	, @date datetime = null
)	
RETURNS datetime
AS
/************************************************************************

	$History: $

*************************************************************************/
BEGIN
	declare @returnValue datetime
	
	
	select @returnValue = case @dayofweek
			when 'Monday' then dateadd( week, datediff(week,0,coalesce(@date,getdate())), 7	)
			when 'Tuesday' then dateadd( week, datediff(week,0,coalesce(@date,getdate())), 8	)
			when 'Wednesday' then dateadd( week, datediff(week,0,coalesce(@date,getdate())), 9	)
			when 'Thursday' then dateadd( week, datediff(week,0,coalesce(@date,getdate())), 10	)
			when 'Friday' then dateadd( week, datediff(week,0,coalesce(@date,getdate())), 11	)
			when 'Satday' then dateadd( week, datediff(week,0,coalesce(@date,getdate())), 12	)
			when 'Sunday' then dateadd( week, datediff(week,0,coalesce(@date,getdate())), 13	)
			end

	return @returnValue	
END
GO	