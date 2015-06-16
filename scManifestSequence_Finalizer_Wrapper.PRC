IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[scManifestSequence_Finalizer_Wrapper]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[scManifestSequence_Finalizer_Wrapper]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[scManifestSequence_Finalizer_Wrapper]
AS
BEGIN
	set nocount on

	declare @finalizeDate datetime
	declare @msg nvarchar(2048)

	set @finalizeDate = convert(varchar, dateadd(d, 1, getdate()), 1)

	set @msg = 'Manifest Sequence Finalizer finalizing for ' + convert(varchar, @finalizeDate, 1)
	exec syncSystemLog_Insert 2, 0, 1, @msg
	print @msg

	exec scManifestSequence_Finalizer @finalizeDate

END
GO	

	