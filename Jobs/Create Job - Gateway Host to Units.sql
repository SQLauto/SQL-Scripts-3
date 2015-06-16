USE [msdb]
GO
/*
	Generic Tempate for scripting a job

	Use the command (CTRL+SHIFT+M) or select from the Query menu option to replace parameter values
	for 
	
		CTRL+SHIFT+M = Specify Values for Paramters
*/
declare @jobId binary(16)
declare @name nvarchar(256)

set @name = N'Syncronex: Gateway Host to Units (' + upper('<dbcatalog, sysname, NSDB>') + ')'

select @jobId = job_id from msdb.dbo.sysjobs where (name = @name)
if @jobId is not null
begin
	exec msdb.dbo.sp_delete_job @job_id=@jobId
	print 'Deleted job ''' + @name + ''''
end
GO

declare @returnCode int
select @returnCode = 0

declare @jobId binary(16)
declare @name nvarchar(256)

--|Add the SyncronexJob category if it doesn't already exist
if not exists (
	select name from msdb.dbo.syscategories where name=N'SyncronexJob' AND category_class=1
)
begin
	exec @returnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'SyncronexJob'
	if (@@error <> 0 OR @returnCode <> 0) 
		goto QuitWithRollback
	else
		print 'Added category ''SyncronexJob''' 
end

begin transaction
	set @name = N'Syncronex: Gateway Host to Units (' + upper('<dbcatalog, sysname, NSDB>') + ')'
		
	exec @returnCode =  msdb.dbo.sp_add_job @job_name=@name, 
			@enabled=1, 
			@notify_level_eventlog=0, 
			@notify_level_email=0, 
			@notify_level_netsend=0, 
			@notify_level_page=0, 
			@delete_level=0, 
			@description=N'No description available.', 
			@category_name=N'SyncronexJob', 
			@owner_login_name=N'<SQL Server, sysname, SQL_SERVER_NAME>\Administrator', @job_id = @jobId OUTPUT
	if (@@error <> 0 OR @returnCode <> 0) 
	begin
		goto QuitWithRollback
	end	
	else
	begin
		print 'Added job: ''' + @name + ''''
		exec sp_add_jobserver @job_id=@jobId, @job_name=null, @server_name=null
	end
	
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create Trigger File', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec scGateway_Create_Trigger_File', 
		@database_name=N'<dbcatalog, sysname, NSDB>', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

declare @cmdExecCommand nvarchar(4000)
set @cmdExecCommand = 
N'"C:\PD\APP\MCCGateway_3.3.0.exe" -Z -B -A -P -T0 -R1-D -XC:\<company abbr., sysname, COMPANY_ABBR>\PD\XML\WinMobGateway_hostbatch.xml -uC:\<company abbr., sysname, COMPANY_ABBR>\PD\XML\xmltoupper.xsl -eC:\<company abbr., sysname, COMPANY_ABBR>\PD\XML\mccmessages.xml -gC:\<company abbr., sysname, COMPANY_ABBR>\PD\log\Gateway_Host\'

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create unit files for collection', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=@cmdExecCommand, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1	

--|  Daily 8pm
set @name = N'Gateway Host to Units Schedule (' + upper('<dbcatalog, sysname, NSDB>') + ')'

exec @returnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=@name, 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20110301, 
		@active_end_date=99991231, 
		@active_start_time=203000, 
		@active_end_time=235959
if (@@error <> 0 or @returnCode <> 0) goto QuitWithRollback

COMMIT transaction
goto EndSave
QuitWithRollback:
    if (@@TRANCOUNT > 0) ROLLBACK transaction
EndSave:

GO

