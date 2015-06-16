set nocount on
--| declarations
declare @beginDateOffset_RelativeToRunOnDay int
declare @endDateOffset_RelativeToRunOnDay int
declare @runonday varchar(9)	--| Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|null
declare @loggingLevel int	
declare @overwriteUserEdits bit
declare @newAccountsOnly bit
declare @delay_seconds int
declare @resetFlag bit
declare @strDelay nvarchar(8)
declare @now datetime

--| set variables
set @beginDateOffset_RelativeToRunOnDay = 1

select @endDateOffset_RelativeToRunOnDay = DATEDIFF(d, getdate(), max(drawdate))
from scDraws

set @runonday = null
set @loggingLevel = null
set @overwriteUserEdits = 0
set @newAccountsOnly = 1
set @delay_seconds = 120

set @now = getdate()

--| run the export
exec support_ForecastScheduler @beginDateOffset_RelativeToRunOnDay, @endDateOffset_RelativeToRunOnDay, @runonday, @loggingLevel, @overwriteUserEdits, @newAccountsOnly, @delay_seconds


--| wait for forecasting to start, then toggle 'NewAccountsOnly' option
set @delay_seconds = 1
set @strDelay = convert(varchar, dateadd(ms, @delay_seconds*1000,0), 114)

/*
	new accounts only forecasts will be very short in duration, so the process could already be complete by the time
	we check the status so just check to see if a forecast has been started.
*/	
if exists (
	select *
	from dbo.support_ForecastDurations(0)
	where ForecastStartTime > @now
)
begin
	set @resetFlag = 1
end
else
begin
	set @resetFlag = 0
end

--/*
while @resetFlag = 0
begin
	waitfor delay @strDelay
	
	if exists (
		select *
		from dbo.support_ForecastDurations(0)
		where ForecastStartTime > @now
	)
	begin
		print 'Forecasting has started, setting ''NewAccountsOnly'' flag = ''flase'''
		set @resetFlag = 1
	end
end

update merc_ControlPanel
set AttributeValue= 'false'
where AttributeName = 'NewAccountsOnly'

