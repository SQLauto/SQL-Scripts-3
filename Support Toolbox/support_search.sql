IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_Search]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_Search]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_Search]
	  @searchString nvarchar(20) = null
AS
/*
	[dbo].[support_Search]
	
	$History:  $
*/
BEGIN
	Set @searchString = '%' + ltrim(rtrim( @searchString ) ) + '%'

	SELECT Distinct 'sproc' as [Object], SO.Name, N'' as [Details]
	FROM sysobjects SO (NOLOCK) 
	INNER JOIN syscomments SC (NOLOCK)
	on SO.Id = SC.ID AND SO.Type = 'P'
	AND SC.Text LIKE @searchString
	
	union all
	
	SELECT	'job' as [Object]
		, j.name
		, 'Step ' + cast(js.step_id as varchar)
			+ case j.enabled when 1 then ' (enabled)' else ' (disabled)' end
			+ ': ' + js.command
		
	FROM	msdb.dbo.sysjobs j
	JOIN	msdb.dbo.sysjobsteps js
		ON	js.job_id = j.job_id 
	WHERE	js.command LIKE @searchString
	
END
GO	