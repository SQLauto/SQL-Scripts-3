USE [nsdb_36]
GO

/****** Object:  StoredProcedure [dbo].[support_DataExportMonitor]    Script Date: 10/29/2014 11:01:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_DataExportMonitor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_DataExportMonitor]
GO

USE [nsdb_36]
GO

/****** Object:  StoredProcedure [dbo].[support_DataExportMonitor]    Script Date: 10/29/2014 11:01:37 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[support_DataExportMonitor]
AS
/*
	[dbo].[support_DataExportMonitor]
	
	$History:  $

	/*
		Data Export Monitor
		
		1)  Look for Run Requests
		2)  Clear run flag
		3)  run export
		
	*/

*/
BEGIN
	set nocount on

	declare @cmd nvarchar(4000)
	declare @args nvarchar(3500)
	declare @exportEnginePath nvarchar(500)  --|leave null to look up path
	declare @result int
	declare @msg nvarchar(1024)

	--print 'data export monitor starting ' + db_name() + '...'
	set @msg = 'data export monitor starting ' + db_name() + '...'
	print @msg
	--exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg
	
	if exists (
		select 1 as [DataExportRequested]
		from syncSystemProperties
		where sysPropertyName = 'RunDataExport'
		and sysPropertyValue = 'True'
	)
	begin	
		--|  get the export engine path
		select @exportEnginePath = v.PropertyValue
		from syncConfigurationProperties p
		join syncConfigurationPropertyValues v
			on p.ConfigurationPropertyId =v.ConfigurationPropertyId
		where p.PropertyDisplayName = 'Path to Data Export Engine'

		--|  get the command arguments
		select @args = sysPropertyValue
		from syncSystemProperties
		where sysPropertyName = 'DataExportCommandArgs'
		
		set @cmd = replace(@exportEnginePath, 'Program Files', 'Progra~1') + ' ' + @args
		print @cmd
		
			
		set @msg = 'An export has been requested with the following arguments: ' + @args
		print @msg
		exec nsSystemLog_Insert @ModuleId=2, @SeverityId=0, @Message=@msg

		--|  clear the run flag
		update syncSystemProperties
		set SysPropertyValue = 'False'
		where SysPropertyName = 'RunDataExport'
	
		--|  run syncExport.exe	
		execute @result = master..xp_cmdshell @cmd

		-- syncExport.exe returns 1 for success, zero for failure
		if @result <> 1
		begin
			raiserror('Data export failed, see system log',16,1)  -- this insures that the job history shows a failure
			
			--| fix invalid state
			IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_FixExportStatus]') AND type in (N'P', N'PC'))
				exec [support_FixExportStatus] @doUpdate=1, @rerun=0
		end
		
	end	


END

GO

