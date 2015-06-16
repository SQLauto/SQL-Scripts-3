declare @beginDate varchar(10)
declare @endDate varchar(10)

declare @beginDate_DaysOut int
declare @endDate_DaysOut int
declare @msg varchar(256)

set @beginDate_DaysOut = 0
set @endDate_DaysOut = 0

set @begindate = convert(varchar, dateadd(d, @beginDate_DaysOut, getdate()), 1)
set @enddate = convert(varchar, dateadd(d, @endDate_DaysOut, getdate()), 1)

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
	set AttributeValue = @beginDate
	where AttributeName = 'BeginDate'
	
	update merc_ControlPanel
	set AttributeValue = @endDate
	where AttributeName = 'EndDate'

	update merc_ControlPanel
	set AttributeValue = '0'
	where AttributeName = 'LoggingLevel'

	update merc_ControlPanel
	set AttributeValue =	NULL
	where AttributeName = 'LogFile'

	update merc_ControlPanel
	set AttributeValue = 'False'
	where AttributeName = 'DiagnosticOutput'

	update merc_ControlPanel
	set AttributeValue = 'Scheduled Job'
	where AttributeName = 'UserName'

	update merc_ControlPanel
	set AttributeValue = '-1'
	where AttributeName = 'UserId'

	update merc_ControlPanel
	set AttributeValue = 'False'
	where AttributeName = 'OverwriteUserEdits'

	update merc_ControlPanel
	set AttributeValue = 'true'
	where AttributeName = 'NewAccountsOnly'
	
	update merc_ControlPanel
	set AttributeValue = 'true'
	where AttributeName = 'EngineRequest'
end
else
begin
	--| Insert an informational message into the System Log
	set @msg = 'Forecast Engine is locked.  The forecast for ''' + @beginDate + ''' to ''' + @endDate + ''' cannot be requested.'
	exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
	print @msg
end