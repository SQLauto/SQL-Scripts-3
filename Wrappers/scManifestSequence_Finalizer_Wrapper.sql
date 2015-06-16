IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[scManifestSequence_Finalizer_Wrapper]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[scManifestSequence_Finalizer_Wrapper]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[scManifestSequence_Finalizer_Wrapper]
AS
/*
	[dbo].[scManifestSequence_Finalizer_Wrapper]
	
	$History:  $
*/
BEGIN
	declare @date datetime
	set @date = dateadd(d, 1, convert( varchar, getdate(), 1) )

	declare @msg nvarchar(256)
	set @msg = 'Finalizer process started for ' + convert( varchar, dateadd(d, 1, getdate()), 1) + '.'
	exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg

	exec scManifestSequence_Finalizer @date


	declare @subject nvarchar(255)

	set @date = getdate()
	set @subject = 'Finalizer for ' + convert(varchar, @date, 1) + ':  SUCCESS'
	set @msg = 'SUCCESS:  Finalizer process completed successfully for ' + convert(varchar, @date, 1) + '.'
	exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg	
END
GO	