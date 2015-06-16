USE [msdb]
GO
/*
	Transaction Log Backup

	Use the command (CTRL+SHIFT+M) or select from the Query menu option to replace parameter values
	for 
	
		CTRL+SHIFT+M = Specify Values for Paramters
*/
declare @jobId binary(16)
declare @name nvarchar(256)

set @name = N'Syncronex:  Backup Transaction Log (' + upper('<dbcatalog, sysname, NSDB>') + ')'

select @jobId = job_id from msdb.dbo.sysjobs where (name = @name)
if @jobId is not null--exists (select job_id from msdb.dbo.sysjobs_view where name = @name)
begin
	exec msdb.dbo.sp_delete_job @job_id=@jobId
	print 'Deleted job ''' + @name + ''''
end
GO

declare @retCode int
select @retCode = 0

declare @jobId binary(16)
declare @name nvarchar(256)

--|Add the SyncronexJob category if it doesn't already exist
if not exists (
	select name from msdb.dbo.syscategories where name=N'SyncronexJob' AND category_class=1
)
begin
	exec @retCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'SyncronexJob'
	if (@@error <> 0 OR @retCode <> 0) 
		goto QuitWithRollback
	else
		print 'Added category ''SyncronexJob''' 
end

begin transaction

	
	set @name = N'Syncronex:  Backup Transaction Log (' + upper('<dbcatalog, sysname, NSDB>') + ')'
	--select @jobId = job_id from msdb.dbo.sysjobs where (name = @name)
		
	exec @retCode =  msdb.dbo.sp_add_job @job_name=@name, 
			@enabled=1, 
			@notify_level_eventlog=0, 
			@notify_level_email=0, 
			@notify_level_netsend=0, 
			@notify_level_page=0, 
			@delete_level=0, 
			@description=
N'Transaction Log Backup.  This job accompanies the Full Database Backup job.  Changes to this job or job schedule should be accompanied by changes to the Database backup job.

Transaction Log backups are appeneded to the "Full" database backup.  The full database backup job should be configured to overwrite the existing file to prevent the backup file from growing beyond the appropriate size.', 
			@category_name=N'SyncronexJob', 
			@owner_login_name=N'<SQL Server, sysname, SQL_SERVER_NAME>\Administrator', @job_id = @jobId OUTPUT
	if (@@error <> 0 OR @retCode <> 0) 
	begin
		goto QuitWithRollback
	end	
	else
	begin
			print 'Added job: ''' + @name + ''''
			exec sp_add_jobserver @job_id=@jobId, @job_name=null, @server_name=null
	end
	
--| Template for TSQL job step
declare @bkpCommand nvarchar(4000)
declare @defaultBackupPath nvarchar(256)	--|  This is the root path of the default backup path

--|  Get the default backup path for SQL Server from the Registry
exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
	, N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer'
	, N'BackupDirectory'
	, @param = @defaultBackupPath OUTPUT
	
	set @bkpCommand = 
N'BACKUP LOG [<dbcatalog, sysname, NSDB>] 
TO  DISK = N''' + @defaultBackupPath + '\<dbcatalog, sysname, NSDB>.bak'' 
WITH NOFORMAT, NOINIT, NAME = N''<dbcatalog, sysname, NSDB> - Transaction Log Backup'', SKIP, NOREWIND, NOUNLOAD, STATS = 10
GO
'
	set @name = N'Transaction Log Backup (' + upper('<dbcatalog, sysname, NSDB>') + ')'

	if not exists (select * from msdb.dbo.sysjobsteps where job_id = @jobId and step_name = N'Transaction Log Backup (' + upper('<dbcatalog, sysname, NSDB>') + ')')			
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
		@command=@bkpCommand, 
			@database_name=N'master', 
			@flags=0
	if (@@error <> 0 OR @retCode <> 0) goto QuitWithRollback	

	
--| Template for CmdExec job step	
/*
	exec @retCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Create unit files for collection', 
			@step_id=2, 
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

--|  Daily 8pm
set @name = N'Transaction Log Backup Schedule (' + upper('<dbcatalog, sysname, NSDB>') + ')'

exec @retCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=@name, 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20101012, 
		@active_end_date=99991231, 
		@active_start_time=210000, 
		@active_end_time=190000
if (@@error <> 0 or @retCode <> 0) goto QuitWithRollback
	
commit transaction
goto EndSave
QuitWithRollback:
    if (@@TRANCOUNT > 0) ROLLBACK transaction
EndSave:

GO

