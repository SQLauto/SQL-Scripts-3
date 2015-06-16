IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_ForecastScheduler]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_ForecastScheduler]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_ForecastScheduler]
	  @beginDateOffset int
	, @endDateOffset int
	, @runonday varchar(9) = null
	, @loggingLevel int = 0		
	, @overwriteUserEdits bit = 0
	, @newAccountsOnly bit = 0
	, @delay_seconds int = null	
AS
BEGIN
	set nocount on

	declare @msg varchar(256)
	declare @startdate nvarchar(10)
	declare @stopdate nvarchar(10)
	declare @today datetime
	declare @forecastLocked bit
	declare @delay nvarchar(8)	
	
	set @today = GETDATE()

	if ( @runonday is not null and ( @runonday <> datename( dw, @today) ) )
	begin
		set @msg = 'This job is configured to run relative to ' + @runonday + ' but today is ' + DATENAME(dw, @today) + '.'  
		exec syncSystemLog_Insert @moduleId=2,@SeverityId=1,@CompanyId=1,@Message=@msg
		print @msg
		return
	end
	
	--|  BeginDate must be less than EndDate
	if ( DATEADD(d, @beginDateOffset, @today) > DATEADD(d, @endDateOffset, @today) )
	begin
		set @msg = 'Begin Date ''' + convert(varchar, DATEADD(d, @beginDateOffset, @today), 1)
			 + ''' is not earlier than End Date ''' + convert(varchar, DATEADD(d, @endDateOffset, @today), 1) + '''.'
		exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
		print @msg
		return
	end
	else 
	begin
		set @startdate = convert(varchar, DATEADD(d, @beginDateOffset, @today), 1)
		set @stopdate = convert(varchar, DATEADD(d, @endDateOffset, @today), 1)
		print 'StartDate: ' + convert(varchar, @startdate, 101)
		print 'StopDate: ' + convert(varchar, @stopdate, 101)
	end
	
	
	if @delay_seconds is not null
	begin
		--|  don't delay more than 1 hour (3600 seconds)
		if @delay_seconds between 1 and 3600
		begin
			set @delay = convert(varchar, dateadd(ms, @delay_seconds*1000,0), 114)
			print 'Delay: ' + @delay + ' (hh:mm:ss)'
		end
		else
		begin
			set @msg = 'Invalid value for delay interval (seconds).'
			exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
			print @msg
			return	
		end	
		
		select @forecastLocked = cast(running.AttributeValue as bit) | cast(requested.AttributeValue as bit)
		from (
			select AttributeValue
			from merc_ControlPanel 
			where ( AppLayer = 'ForecastEngine' 
			and AttributeName = 'EngineLock' )
			) as running
		join (
			select AttributeValue
			from merc_ControlPanel 
			where ( AppLayer = 'ForecastEngine' 
			and AttributeName = 'EngineRequest' )
			) as requested
		on 1 = 1

		while @forecastLocked <> 0
		begin
			set @msg = 'A forecast is already running or has been requested to run, delaying ' + cast(@delay_seconds as nvarchar) + ' seconds.'
			exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
			print @msg
			
			waitfor delay @delay
			
			select @forecastLocked = cast(running.AttributeValue as bit) | cast(requested.AttributeValue as bit)
			from (
				select AttributeValue
				from merc_ControlPanel 
				where ( AppLayer = 'ForecastEngine' 
				and AttributeName = 'EngineLock' )
				) as running
			join (
				select AttributeValue
				from merc_ControlPanel 
				where ( AppLayer = 'ForecastEngine' 
				and AttributeName = 'EngineRequest' )
				) as requested
			on 1 = 1
		end
	end
	else
	begin		
		--|no delay configured, check status and abort if necessary
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
			return
		end
	end	

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
		when 'OverwriteUserEdits' then 
			case @overwriteUserEdits when 0 then 'False' else 'True' end
		when 'NewAccountsOnly' then 
			case @newAccountsOnly when 0 then 'False' else 'True' end
		else AttributeValue
		end
	where AppLayer = 'ForecastEngine'
			
	--| Insert an informational message into the System Log
	set @msg = 'A forecast has been initiated for date range ''' + @startdate + ''' to ''' + @stopdate + '''.'
	exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
	print @msg

END
GO	