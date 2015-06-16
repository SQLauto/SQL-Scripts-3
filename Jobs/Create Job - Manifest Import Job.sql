USE [msdb]
GO
/*
	Generic Tempate for scripting a job

	Use the command (CTRL+SHIFT+M) or select from the Query menu option to replace parameter values
	for 
	
		CTRL+SHIFT+M = Specify Values for Paramters
*/
declare @jobId binary(16)
declare @jobName nvarchar(256)

set @jobName = N'Syncronex:  Manifest Import (' + upper('<dbcatalog, sysname, NSDB>') + ')'

select @jobId = job_id from msdb.dbo.sysjobs where (name = @jobName)
if @jobId is not null
begin
	exec msdb.dbo.sp_delete_job @job_id=@jobId
	print 'Deleted job ''' + @jobName + ''''
end
GO

declare @jobName nvarchar(256)
declare @jobCategory nvarchar(256)

set @jobCategory = N'<jobCategory, sysname, Category>'
set @jobName = N'Syncronex:  Manifest Import (' + upper('<dbcatalog, sysname, NSDB>') + ')'

declare @returnCode int
select @returnCode = 0

declare @jobId binary(16)

--|Add the <jobCategory, sysname, Job Category Name> category if it doesn't already exist
if not exists (
	select name from msdb.dbo.syscategories where name=@jobCategory AND category_class=1
)
begin
	exec @returnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'<jobCategory, sysname, Job Category Name>'
	if (@@error <> 0 OR @returnCode <> 0) 
		goto QuitWithRollback
	else
		print 'Added category ''<jobCategory, sysname, Job Category Name>''' 
end

begin transaction
	set @jobName = N'Syncronex:  Manifest Import (' + upper('<dbcatalog, sysname, NSDB>') + ')'
		
	exec @returnCode =  msdb.dbo.sp_add_job @job_name=@jobName, 
			@enabled=1, 
			@notify_level_eventlog=0, 
			@notify_level_email=0, 
			@notify_level_netsend=0, 
			@notify_level_page=0, 
			@delete_level=0, 
			@description=N'No description available.', 
			@category_name=N'<jobCategory, sysname, Job Category Name>', 
			@owner_login_name=N'sa', @job_id = @jobId OUTPUT
	if (@@error <> 0 OR @returnCode <> 0) 
	begin
		goto QuitWithRollback
	end	
	else
	begin
		print 'Added job: ''' + @jobName + ''''
		exec sp_add_jobserver @job_id=@jobId, @job_name=null, @server_name=null
	end
	
	EXEC @returnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'nsImportWrapper.cmd', 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_success_step_id=0, 
			@on_fail_action=2, 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'CmdExec', 
			@command=N'"<Default Path, sysname, C:\Progra~1\Syncronex\SingleCopy>\bin\ImportExport\<dbcatalog, sysname, nsdb>\nsImportWrapper.cmd"', 
			@flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @returnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @returnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily Manifest Import Schedule (<dbcatalog, sysname, nsdb>)', 
				@enabled=1, 
				@freq_type=8, 
				@freq_interval=127, 
				@freq_subday_type=1, 
				@freq_subday_interval=0, 
				@freq_relative_interval=0, 
				@freq_recurrence_factor=1, 
				@active_start_date=20100118, 
				@active_end_date=99991231, 
				@active_start_time=200000, 
				@active_end_time=235959
	IF (@@ERROR <> 0 OR @returnCode <> 0) GOTO QuitWithRollback
	
COMMIT transaction
goto EndSave
QuitWithRollback:
    if (@@TRANCOUNT > 0) ROLLBACK transaction
EndSave:

GO

