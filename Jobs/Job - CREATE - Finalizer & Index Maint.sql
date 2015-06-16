DECLARE @jobId BINARY(16)
select @jobId = job_id from msdb.dbo.sysjobs where (name = N'Syncronex: Manifest Finalizer (<dbcatalog, sysname, nsdb>)')

IF  EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'Syncronex: Manifest Finalizer (<dbcatalog, sysname, nsdb>)')
begin
	EXEC msdb.dbo.sp_delete_job @job_id=@jobId
	PRINT 'Deleted job ''Syncronex: Manifest Finalizer (<dbcatalog, sysname, nsdb>)'''
end
go

BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0
	IF NOT EXISTS (
		SELECT name FROM msdb.dbo.syscategories WHERE name=N'SyncronexJob' AND category_class=1
	)
	BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'SyncronexJob'
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
			GOTO QuitWithRollback
		ELSE
			print 'Added category ''SyncronexJob''' 
	END

	DECLARE @jobId BINARY(16)
	select @jobId = job_id from msdb.dbo.sysjobs where (name = N'Syncronex: Manifest Finalizer (<dbcatalog, sysname, nsdb>)')

	if (@jobId is NULL)
	BEGIN
	EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Syncronex: Manifest Finalizer (<dbcatalog, sysname, nsdb>)', 
			@enabled=1, 
			@notify_level_eventlog=0, 
			@notify_level_email=0, 
			@notify_level_netsend=0, 
			@notify_level_page=0, 
			@delete_level=0, 
			@description=N'No description available.', 
			@category_name=N'SyncronexJob', 
			@owner_login_name=N'nsAdmin', @job_id = @jobId OUTPUT
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
		GOTO QuitWithRollback
	ELSE
		print 'Added job: ''Syncronex: Manifest Finalizer (<dbcatalog, sysname, nsdb>)'''

	END
	IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 1)
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Log:  Finalizer Starting', 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=3, 
			@on_success_step_id=0, 
			@on_fail_action=3, 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'TSQL', 
			@command=N'
	declare @date datetime
	set @date = getdate()

	declare @msg nvarchar(256)
	set @msg = ''Finalizer process started for '' + convert( varchar, dateadd(d, 1, getdate()), 1) + ''.''
	exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
	', 
			@database_name=N'<dbcatalog, sysname, nsdb>', 
			@flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 2)
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run Finalizer for Tomorrow', 
			@step_id=2, 
			@cmdexec_success_code=0, 
			@on_success_action=4, 
			@on_success_step_id=3, 
			@on_fail_action=4, 
			@on_fail_step_id=4, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'TSQL', 
			@command=N'declare @date datetime

	set @date = dateadd(d, 1, convert( varchar, getdate(), 1) )

	exec scManifestSequence_Finalizer @date', 
			@database_name=N'<dbcatalog, sysname, nsdb>', 
			@flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 3)
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Log:  Success', 
			@step_id=3, 
			@cmdexec_success_code=0, 
			@on_success_action=4, 
			@on_success_step_id=5, 
			@on_fail_action=4, 
			@on_fail_step_id=5, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'TSQL', 
			@command=N'
	declare @date datetime
	declare @subject nvarchar(255)
	declare @msg nvarchar(256)

	set @date = getdate()
	set @subject = ''Finalizer for '' + convert(varchar, @date, 1) + '':  SUCCESS''
	set @msg = ''SUCCESS:  Finalizer process completed successfully for '' + convert(varchar, @date, 1) + ''.''
	exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg

	exec nsMessages_INSERTNOTALREADY 
		@nsSubject=@subject
		, @nsMessageText=@msg
		, @nsFromId = 8
		, @nsToId = 0
		, @nsGroupId = 2
		, @nsTime = @date
		, @nsPriorityId = 2 	--|  Normal
		, @nsStatusId = 3  	--|
		, @nsTypeId = 1	--|  Memo 
		, @nsStateId = 1
		, @nsCompareTime = @date
		, @nsAccountId = 0

	', 
			@database_name=N'<dbcatalog, sysname, nsdb>', 
			@flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 4)
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Log:  Failure', 
			@step_id=4, 
			@cmdexec_success_code=0, 
			@on_success_action=4, 
			@on_success_step_id=5, 
			@on_fail_action=4, 
			@on_fail_step_id=5, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'TSQL', 
			@command=N'
	declare @date datetime
	declare @subject nvarchar(255)
	declare @msg nvarchar(256)

	set @date = getdate()
	set @subject = ''Finalizer for '' + convert(varchar, @date, 1) + '':  SUCCESS''
	set @msg = ''FAILED:  Finalizer process failed for '' + convert(varchar, @date, 1) + ''.''

	exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg

	exec nsMessages_INSERTNOTALREADY 
		@nsSubject=@subject
		, @nsMessageText=@msg
		, @nsFromId = 8
		, @nsToId = 0
		, @nsGroupId = 2
		, @nsTime = @date
		, @nsPriorityId = 3 --|  High
		, @nsStatusId = 3  	--|
		, @nsTypeId = 1		--|  Memo 
		, @nsStateId = 1
		, @nsCompareTime = @date
		, @nsAccountId = 0

	', 
			@database_name=N'<dbcatalog, sysname, nsdb>', 
			@flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	IF NOT EXISTS (SELECT * FROM msdb.dbo.sysjobsteps WHERE job_id = @jobId and step_id = 5)
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Index Maintenance', 
			@step_id=5, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_success_step_id=0, 
			@on_fail_action=2, 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'TSQL', 
			@command=N'exec syncIndexMaintenance', 
			@database_name=N'<dbcatalog, sysname, nsdb>', 
			@flags=0
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Finalizer Schedule (<dbcatalog, sysname, nsdb>)', 
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
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

