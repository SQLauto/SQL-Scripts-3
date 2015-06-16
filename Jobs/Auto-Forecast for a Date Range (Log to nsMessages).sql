begin tran

declare @beginDate varchar(10)
declare @endDate varchar(10)

declare @beginDate_DaysOut int
declare @endDate_DaysOut int

set @beginDate_DaysOut = -7
set @endDate_DaysOut = 7

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
	declare @msg varchar(256)
	set @msg = 'Auto-Forecast beginning for date range ''' + @beginDate + ''' to ''' + @endDate + '''.'
	exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
	--|print @msg

	declare @date datetime
	set @date = getdate()

	exec nsMessages_INSERTNOTALREADY 
		@nsSubject='Auto-Forecast'
		, @nsMessageText=@msg
		, @nsFromId = 8
		, @nsToId = 0
		, @nsGroupId = 2
		, @nsTime = @date
		, @nsPriorityId = 2 	--|  Normal
		, @nsStatusId = 3  	--|
		, @nsTypeId = 1		--|  Memo 
		, @nsStateId = 1
		, @nsCompareTime = @date
		, @nsAccountId = 0

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

commit tran