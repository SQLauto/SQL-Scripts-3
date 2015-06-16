begin tran

select sj.name
	, sjs.command, sjs.*
from msdb.dbo.sysjobs sj
join msdb.dbo.sysjobsteps sjs
	on sj.job_id = sjs.job_id
where sj.name like '%import%'
and sj.enabled = 0
and sjs.subsystem = 'TSQL'

update msdb.dbo.sysjobsteps
	set database_name = replace(database_name, 'nsdb', 'nsdb27')	
from msdb.dbo.sysjobs sj
join msdb.dbo.sysjobsteps sjs
	on sj.job_id = sjs.job_id
where sj.name like '%import%'
and sj.enabled = 0
and sjs.subsystem = 'TSQL'

update msdb.dbo.sysjobsteps
	set command = replace(command, 'Single Copy 3.6 - Manifest Import (DSI)', 'Manifest Import (' + database_name + ')')
from msdb.dbo.sysjobs sj
join msdb.dbo.sysjobsteps sjs
	on sj.job_id = sjs.job_id
where sj.name like '%import%'
and sj.enabled = 0
and sjs.subsystem = 'TSQL'


update msdb.dbo.sysjobs
	set enabled = 1
from msdb.dbo.sysjobs sj
where sj.name like '%import%'
and sj.enabled = 0

select sj.name
	, sjs.database_name
	, sjs.command
from msdb.dbo.sysjobs sj
join msdb.dbo.sysjobsteps sjs
	on sj.job_id = sjs.job_id
where sj.name like '%import%'
and sj.enabled = 0
and sjs.subsystem = 'TSQL'

commit tran

--Single Copy 3.6 - Manifest Import (DSI)
--DECLARE @RC int  DECLARE @ModuleId int  DECLARE @SeverityId int  DECLARE @CompanyId int  DECLARE @Message nvarchar(1024)  DECLARE @GroupId nvarchar(36)  DECLARE @ProcessId int  DECLARE @ThreadId int  DECLARE @DeviceId int  DECLARE @UserId int  DECLARE @Source nvarchar(10)  SELECT @ModuleId = 2  SELECT @SeverityId = 1  SELECT @CompanyId = 1  SELECT @Message = N'Single Copy 3.6 - Manifest Import (DSI):  Job Started'  SELECT @GroupId = NULL  SELECT @ProcessId = NULL  SELECT @ThreadId = NULL  SELECT @DeviceId = NULL  SELECT @UserId = NULL  SELECT @Source = NULL  EXEC @RC = [nsdb_dan].[dbo].[syncSystemLog_Insert] @ModuleId, @SeverityId, @CompanyId, @Message, @GroupId, @ProcessId, @ThreadId, @DeviceId, @UserId, @Source  DECLARE @PrnLine nvarchar(4000)  PRINT 'Stored Procedure: nsdb.dbo.syncSystemLog_Insert'  SELECT @PrnLine = ' Return Code = ' + CONVERT(nvarchar, @RC)  PRINT @PrnLine