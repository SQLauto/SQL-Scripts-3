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
set @jobName = 'Syncronex:  ' + '<job_name, sysname, JOB_NAME>'
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
declare @bkpCommand nvarchar(4000)
declare @defaultBackupPath nvarchar(256)	--|  This is the root path of the default backup path

--|  Get the default backup path for SQL Server from the Registry
exec master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
	, N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer'
	, N'BackupDirectory'
	, @param = @defaultBackupPath OUTPUT
	
	set @bkpCommand = N'
BACKUP DATABASE [<db_catalog, sysname, NSDB>] 
TO  DISK = N''' + @defaultBackupPath + '\<db_catalog, sysname, NSDB>.bak'' 
WITH NOFORMAT, INIT,  NAME = N''<db_catalog, sysname, NSDB> - Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N''<db_catalog, sysname, NSDB>''
 and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N''<db_catalog, sysname, NSDB>'' )
if @backupSetId is null begin raiserror(N''Verify failed. Backup information for database ''''<db_catalog, sysname, NSDB>'''' not found.'', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N''' + @defaultBackupPath + '\<db_catalog, sysname, NSDB>.bak'' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO
		'
	declare @name nvarchar(256)
	set @name = N'Full Backup (' + upper('<db_catalog, sysname, NSDB>') + ')'

	if not exists (select * from msdb.dbo.sysjobsteps where job_id = @jobId and step_name = @name )			
	exec @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=@name, 
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
	if (@@error <> 0 OR @ReturnCode <> 0) goto QuitWithRollback	

set @name = @jobName

EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=@name, 
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