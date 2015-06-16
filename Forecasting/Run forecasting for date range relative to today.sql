begin tran

set nocount on

declare @runonday nvarchar(9)
set @runonday = 'Thursday'

declare @msg varchar(256)

--|Check for currently running exports or pending run requests
if exists ( 
	select 1 as [ForecastEngineRunning]
	from merc_ControlPanel 
	where ( AppLayer = 'ForecastEngine' 
			and AttributeName = 'EngineLock'
			and AttributeValue = 'True' )
		or ( AppLayer = 'ForecastEngine' 
			and AttributeName = 'EngineRequest'
			and AttributeValue = 'True' )
)		
begin
	set @msg = 'An auto-forecast could not be initiated because a forecast has already been requested or is already running.'
	exec syncSystemLog_Insert @moduleId=2,@SeverityId=1,@CompanyId=1,@Message=@msg
	print @msg
end
else
begin
	declare @userId int
	declare @startdate nvarchar(10)
	declare @stopdate nvarchar(10)
	declare @today datetime
	declare @args nvarchar(512)

	set @today = GETDATE()

	select @userId = isnull(UserId,0)
	from Users
	where UserName = 'admin@singlecopy.com'

	if ( datename( dw, @today) = @runonday)
	begin
		set @startdate = convert(varchar, DATEADD(d, 4, @today), 1)
		set @stopdate = convert(varchar, DATEADD(d, 6, @today), 1)
			
		--print datename(dw, @startdate)
		--print datename(dw, @stopdate)	
			
		update merc_ControlPanel
		set AttributeValue = case AttributeName
			when 'BeginDate' then @startdate
			when 'EndDate' then @stopdate
			when 'LoggingLevel' then '0'
			when 'LogFile' then NULL
			when 'DiagnosticOutput' then 'False'
			when 'EngineRequest' then 'true'
			when 'UserName' then 'Scheduled Job'
			when 'UserId' then '-1'
			when 'OverwriteUserEdits' then 'False'
			when 'NewAccountsOnly' then 'False'
			else AttributeValue
			end
		where AppLayer = 'ForecastEngine'
			
		--| Insert an informational message into the System Log
		set @msg = 'A forecast has been initiated for date range ''' + @startdate + ''' to ''' + @stopdate + '''.'
		exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
		print @msg
	end
	else
	begin
		set @msg = 'This job is configured to run relative to ' + @runonday + ' but today is ' + DATENAME(dw, @today) + '.'  
		exec syncSystemLog_Insert @moduleId=2,@SeverityId=1,@CompanyId=1,@Message=@msg
		print @msg
	end
end

select *
from merc_ControlPanel
where AppLayer = 'ForecastEngine'


rollback tran