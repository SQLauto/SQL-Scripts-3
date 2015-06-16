USE [nsdb_ric]
GO
/****** Object:  StoredProcedure [dbo].[support_FixExportStatus]    Script Date: 07/23/2014 10:47:38 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[support_FixExportStatus]
	      @doUpdate int = 0
	    , @rerun int = 0
AS
/*
	[dbo].[support_FixExportStatus]
	
	$History:  $
*/
BEGIN
	set nocount on
	
	--|  Declarations
	declare @msg nvarchar(1024)
	declare @rowcount int
	declare @args nvarchar(2000)
	
	print 'Export Status Summary:'

	select @msg = '  DataExpotRunning: ''' + SysPropertyValue + ''''
	from syncSystemProperties
	where SysPropertyName = 'DataExportRunning'
	print @msg
	
	select @rowcount = COUNT(*) 
		--ExportTypeDescription, st.PSName, u.UserName, ex.LastUpdated
	from scDataExchangeControls ex
	join dd_scExportTypes typ
		on ex.ExchangeTypeId = typ.ExportTypeId
	join dd_scProcessingStates st
		on ex.ExchangeStatus = st.ProcessingStateId	
	join Users u
		on ex.UserId = u.UserID
	where ExchangeStatus = 1
	
	if @rowcount > 1
	begin
		select ExportTypeDescription, st.PSName, u.UserName, ex.LastUpdated
		from scDataExchangeControls ex
		join dd_scExportTypes typ
			on ex.ExchangeTypeId = typ.ExportTypeId
		join dd_scProcessingStates st
			on ex.ExchangeStatus = st.ProcessingStateId	
		join Users u
			on ex.UserId = u.UserID
		where ExchangeStatus = 1
		order by LastUpdated desc
		
		set @msg = '  Found ' + cast(@rowcount as varchar) + ' exports in ''pending'' status.  These records will bet set to ''done''.'
		print @msg
	end

	if @rowcount = 1
	begin
		select @msg = '  The ''' + rtrim(ExportTypeDescription) + ''' requested by ' + u.UserName + ' on ' 
			--+ convert(varchar, ex.LastUpdated, 118)
			+ cast(ex.LastUpdated as varchar)
			+ ' is in ''' + st.PSName + ''' status.  This record will be set to ''done''.'
		from scDataExchangeControls ex
		join dd_scExportTypes typ
			on ex.ExchangeTypeId = typ.ExportTypeId
		join dd_scProcessingStates st
			on ex.ExchangeStatus = st.ProcessingStateId	
		join Users u
			on ex.UserId = u.UserID
		where ExchangeStatus = 1
		order by LastUpdated desc
		print @msg
	end	
	
	if @rowcount = 0
	begin
		set @msg = '  No exports in ''pending'' status in scDataExchangeControls.  Nothing to update.'
		print @msg
	end		
	
	select @args = SysPropertyValue
	from syncSystemProperties
	where SysPropertyName = 'DataExportCommandArgs'
	
	print '  Current CommandArgs value:  ' + @args
	

	print ''
	print 'Update Summary:  '
	
	if @doUpdate = 1
	begin
		update syncSystemProperties
		set SysPropertyValue = 'False'
		where SysPropertyName = 'DataExportRunning'
		and SysPropertyValue = 'True'
		set @rowcount = @@ROWCOUNT
		set @msg = case 
			when @rowcount = 1 then '  Export was stuck in ''Running'' status... DataExportRunning set to False.'
			else '  DataExportRunning is already set to ''False''.  Nothing to update.'
			end
			print @msg
		
		update scDataExchangeControls
		set ExchangeStatus = 3
		where ExchangeStatus = 1
		--and datediff(d, LastUpdated, GETDATE()) = 0
		set @rowcount = @@ROWCOUNT
		set @msg = '  Reset status to ''done'' for ' + CAST(@rowcount as varchar) + ' ''pending'' exports.'
		print @msg
	end
	else
	begin
		print '  @doUpdate=0.  Nothing was updated.'
	end

	print ''
	print 'Re-run Summary:  '
		
	if @rerun = 1
	begin
		print '  Export will be re-run with CommandArgs:  ' + @args
		declare @sql nvarchar(1000)
		set @sql = 'E:\Progra~1\Syncronex\SingleCopy\bin\SyncExport.exe ' + @args
		print @sql
		exec xp_cmdshell @sql 

		--update syncSystemProperties
		--set SysPropertyValue = 'True'
		--where SysPropertyName = 'RunDataExport'
	end
	else
	begin
		print '  @rerun=0.  Export will NOT be run automatically.'
		
		declare @enginePath nvarchar(100)
		select @enginePath = v.PropertyValue
		from syncConfigurationProperties p
		join syncConfigurationPropertyValues v
			on p.ConfigurationPropertyId = v.ConfigurationPropertyId
		where PropertyName = 'DataExportEnginePath'
		
		print '  Command Line Syntax:  ' + @enginePath + ' ' + @args

	end

END
