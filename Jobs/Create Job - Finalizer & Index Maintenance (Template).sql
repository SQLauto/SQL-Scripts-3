USE [msdb]
GO
/*
	Generic Tempate for scripting a job

	Use the command (CTRL+SHIFT+M) or select from the Query menu option to replace parameter values
	for 
	
		CTRL+SHIFT+M = Specify Values for Paramters
*/
DECLARE @jobName nvarchar(50)
DECLARE @jobCategoryName nvarchar(50)
DECLARE @dbCatalog nvarchar(25)
DECLARE @jobOwner nvarchar(25)

set @dbCatalog = N'<db_catalog, sysname, NSDB>'
set @jobName = '<job_name, sysname, Syncronex:  Finalizer & Reindex >'
set @jobCategoryName = N'<job_category, sysname, SyncronexJob>'
set @jobOwner = N'<job_owner, sysname, sa>'

set @jobName = @jobName + UPPER( N' (<db_catalog, sysname, NSDB>)' )

DECLARE @jobId BINARY(16)
select @jobId = job_id from msdb.dbo.sysjobs where (name = @jobName)

--|  Delete the job if it already exists
IF  @jobId is not null
BEGIN
	print 'Job ''' + @jobName + ''' already exists.  Deleting job.'
	EXEC msdb.dbo.sp_delete_job @job_id=@jobId
END

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

--|  Add Job Category, if necessary
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=@jobCategoryName AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=@jobCategoryName
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END



begin transaction
	set @jobName = N'Syncronex:  Finalizer & Reindex (' + upper(@dbCatalog) + ')'
		
	exec @returnCode =  msdb.dbo.sp_add_job @job_name=@jobName, 
			@enabled=1, 
			@notify_level_eventlog=0, 
			@notify_level_email=0, 
			@notify_level_netsend=0, 
			@notify_level_page=0, 
			@delete_level=0, 
			@description=N'No description available.', 
			@category_name=@jobCategoryName, 
			@owner_login_name=@jobOwner, @job_id = @jobId OUTPUT
	if (@@error <> 0 OR @returnCode <> 0) 
	begin
		goto QuitWithRollback
	end	
	else
	begin
		print 'Added job: ''' + @jobName + ''''
		exec sp_add_jobserver @job_id=@jobId, @job_name=null, @server_name=null
	end
	
/****** Object:  Step [Log:  Finalizer Starting]    Script Date: 03/02/2011 09:32:01 ******/
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
		@database_name=@dbCatalog, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run Finalizer for Tomorrow]    Script Date: 03/02/2011 09:32:01 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run Finalizer for Tomorrow', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=3, 
		@on_fail_action=4, 
		@on_fail_step_id=5, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @date datetime

	set @date = dateadd(d, 1, convert( varchar, getdate(), 1) )

	exec scManifestSequence_Finalizer @date', 
		@database_name=@dbCatalog, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Index Maintenance - Log Success Path]    Script Date: 03/02/2011 09:32:02 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Index Maintenance - Log Success Path', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=4, 
		@on_fail_action=4, 
		@on_fail_step_id=5, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbo.syncIndexMaintenance 
	  @db_name=''nsdb_star''
	, @fillfactor=null
	, @fragThreshold_Reorg_LowerLimit=10
	, @fragThreshold_Rebuild_LowerLimit=30
', 
		@database_name=@dbCatalog, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Log:  Success]    Script Date: 03/02/2011 09:32:02 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Log:  Success', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
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
		, @nsFromId = 1
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
		@database_name=@dbCatalog, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Index Maintenance - Log Failure Path]    Script Date: 03/02/2011 09:32:02 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Index Maintenance - Log Failure Path', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=6, 
		@on_fail_action=4, 
		@on_fail_step_id=6, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbo.syncIndexMaintenance 
	  @db_name=@dbCatalog
	, @fillfactor=null
	, @fragThreshold_Reorg_LowerLimit=10
	, @fragThreshold_Rebuild_LowerLimit=30
', 
		@database_name=@dbCatalog, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Log:  Failure]    Script Date: 03/02/2011 09:32:02 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Log:  Failure', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=2, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
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
		@database_name=@dbCatalog, 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

set @jobName = N'Finalizer Schedule (' + upper(@dbCatalog) + ')'
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=@jobName, 
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
	
COMMIT transaction
goto EndSave
QuitWithRollback:
    if (@@TRANCOUNT > 0) ROLLBACK transaction
EndSave:

GO

