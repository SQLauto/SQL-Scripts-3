declare @beginDate varchar(10)
declare @endDate varchar(10)

declare @beginDate_DaysOut int
declare @endDate_DaysOut int
declare @msg varchar(256)

set @beginDate_DaysOut = 0
set @endDate_DaysOut = 0

set @begindate = convert(varchar, dateadd(d, @beginDate_DaysOut, getdate()), 110)
set @enddate = convert(varchar, dateadd(d, @endDate_DaysOut, getdate()), 110)

--|print 'Begin Date: ' + @beginDate
--|print 'Begin Date: ' + @endDate

if not exists ( 
	select 1 as [ForecastEngineRunning]
	from merc_ControlPanel 
	where AppLayer = 'ForecastEngine'
	and AttributeName = 'EngineLock'
	and AttributeValue = 'True' 
)
begin
	--| Insert an informational message into the System Log
	set @msg = 'Auto-Forecast beginning for date range ''' + @beginDate + ''' to ''' + @endDate + '''.'
	exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
	print @msg

	update merc_ControlPanel
	set AttributeValue = case AttributeName
		when 'BeginDate' then @beginDate
		when 'EndDate' then @endDate
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
end
else
begin
	--| Insert an informational message into the System Log
	set @msg = 'Forecast Engine is locked.  The forecast for ''' + @beginDate + ''' to ''' + @endDate + ''' cannot be requested.'
	exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
	print @msg
end