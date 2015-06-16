IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[<Function_Name, sysname, function_name>]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[<Function_Name, sysname, function_name>]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE FUNCTION [dbo].[<Function_Name, sysname, function_name>] (
	  @param1 nvarchar(20) = null
	, @param2 int = null
	, @param3 datetime = null
)	
RETURNS @table TABLE
(
	column_1 int
	,column_2 datetime
)

AS
/************************************************************************

	$History: $

*************************************************************************/
BEGIN


	insert into @table
	select 'value1', 'value2'

	RETURN
END
GO	