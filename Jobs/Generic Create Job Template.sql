USE [msdb]
GO
/*
	Use the following command (or select from the Query menu option) to replace parameter values
	for dbcatalog and owner
	
		CTRL+SHIFT+M = Specify Values for Paramters

*/
DECLARE @jobName nvarchar(50)
DECLARE @jobCategoryName nvarchar(50)
DECLARE @dbCatalog nvarchar(25)
DECLARE @jobOwner nvarchar(25)

set @dbCatalog = N'<db_catalog, sysname, NSDB>'
set @jobName = '<job_name, sysname, JOB_NAME>'
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


--DECLARE @jobId BINARY(16)
--|  Add the job
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@jobName, 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'<job_description, sysname, No description available>', 
		@category_name=@jobCategoryName, 
		@owner_login_name=@jobOwner, @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) 
	GOTO QuitWithRollback
ELSE
	print 'Added job: ''' + @jobName + ''''
	
--| Template for TSQL job step
	/*
	set @name = 'TSQL Job Step Name'

	if not exists (select * from msdb.dbo.sysjobsteps where job_id = @jobId and step_name = @name)			
	exec @retCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=@name, 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_success_step_id=0, 
			@on_fail_action=2, 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'TSQL', 
			@command=N'exec storedProcedure', 
			@database_name=N'<db_catalog, sysname, NSDB>', 
			@flags=0
	if (@@error <> 0 OR @retCode <> 0) goto QuitWithRollback	
	*/

--| Template for TSQL job step
/*
	set @name = 'Powershell Job Step Name'
	
	exec @retCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=@name, 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$today = get-date
$beginDate = $today.AddDays(1).ToShortDateString()
$endDate = $today.AddDays(6).ToShortDateString()
&"E:\Program Files (x86)\Syncronex\SingleCopy\bin\syncExport.exe" Custom "E:\Program Files (x86)\Syncronex\SingleCopy\DataIO\Export_roa\CustomExport_Forecast_Filtered.xml" /p "StartDate=$beginDate,StopDate=$endDate"', 
		@database_name=N'master', 
		@flags=0
*/
	
--| Template for CmdExec job step	
/*
	set @name = 'CmdExec Job Step Name'
	if not exists (select * from msdb.dbo.sysjobsteps where job_id = @jobId and step_name = @name)
	exec @retCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=@name, 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_success_step_id=0, 
			@on_fail_action=2, 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'CmdExec', 
			@command=N'C:\foo.exe', 
			@flags=0
	if (@@error <> 0 OR @retCode <> 0) goto QuitWithRollback
	exec @retCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1	
*/

EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'<company_name, sysname, Syncronex>:  <job_name, sysname, Job Name> Job Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20091207, 
		@active_end_date=99991231, 
		@active_start_time=180000, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
	IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO