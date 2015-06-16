begin tran
/*
	EXPORT
*/
--|if forecast is running, delay the export
declare @delay_seconds int
declare @forecastRunning bit
declare @exportRunning bit
declare @msg nvarchar(400)

set @delay_seconds = 60

--|convert delay into string
declare @strDelay nvarchar(8)
set @strDelay = convert(varchar, dateadd(ms, @delay_seconds*1000,0), 114)

--|check the status of forecasting
select @forecastRunning = case sum( cast( cast( AttributeValue as bit) as int ) ) 
	when 0 then 'False'
	else 'True'
	end
from merc_ControlPanel 
where AppLayer = 'ForecastEngine' 
and AttributeName in ( 'EngineLock', 'EngineRequest' ) 

--|if forecasting is running, delay the export...
while @forecastRunning = 'True'
begin
	set @msg = 'Forecast is running, delaying forecasted draw export ' + cast(@delay_seconds as nvarchar) + '.'
	waitfor delay @strDelay
	
	select @forecastRunning = case sum( cast( cast( AttributeValue as bit) as int ) ) 
		when 0 then 'False'
		else 'True'
		end
	from merc_ControlPanel 
	where AppLayer = 'ForecastEngine' 
	and AttributeName in ( 'EngineLock', 'EngineRequest' )
end

--| declarations
declare @today datetime
declare @dowToday nvarchar(10)

declare @beginDateOffset_RelativeToRunOnDay int
declare @endDateOffset_RelativeToRunOnDay int
declare @runonday varchar(9)	--| Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|null
declare @exportType varchar(9)	--| Return|Adjustment|Forecast|Custom|Invoice
declare @pathToConfigFile nvarchar(1000)
declare @configFile nvarchar(100)
declare @pubFrequency int

/*
	Monday - Forecast for Tue, Wed (+1, +2)
	Tuesday #1 - Forecast for Thu, Fri (+2, +3)
	Tuesday #2 - Forecast for Sun (+12)
	Wednesday - Forecast for Sat (+3)
	Friday - Forecast for Mon (+3)
	
*/

set @today = convert(varchar, getdate(), 1)
set @dowToday = datename(dw, @today)
set @exportType = 'Forecast'
set @configFile = 'WeeklyForecastExport.xml'
set @pathToConfigFile = 'E:\Program Files (x86)\Syncronex\SingleCopy\DataIO\nsdb_ajc\'

print @dowToday

create table #schedule ( runonday nvarchar(9), begindateoffset int, enddateoffset int, frequency int ) 
insert into #schedule 
select 'Monday', 1, 2, 12
union all 
select 'Tuesday', 2, 3, 48
union all 
select 'Wednesday', 3, 3, 64
union all 
select 'Friday', 3, 3, 2


--|review
select *, dbo.support_DayNames_FromFrequency(Frequency) as [FrequencyDayList]
	, convert(varchar, dbo.support_NextDate(runonday,null), 101) as [RunOnDate]
	, convert(varchar, dateadd(d, begindateoffset, dbo.support_NextDate(runonday,null)),101) as [BeginDate]
	, convert(varchar, dateadd(d, enddateoffset,  dbo.support_NextDate(runonday,null)),101) as [EndDate]
	, datename( dw, dateadd(d, begindateoffset,  dbo.support_NextDate(runonday,null)) ) as [BeginDay]
	, datename( dw, dateadd(d, enddateoffset,  dbo.support_NextDate(runonday,null)) ) as [EndDay]
from #schedule

--| set variables
set @beginDateOffset_RelativeToRunOnDay = 2
set @endDateOffset_RelativeToRunOnDay = 8
set @runonday = 'Tuesday'
set @pubFrequency = 48
set @delay_seconds = 15

--| run the export
--exec support_ForecastExportScheduler @beginDateOffset_RelativeToRunOnDay, @endDateOffset_RelativeToRunOnDay, @runonday, @pubFrequency, @exportType, @pathToConfigFile, @configFile, @delay_seconds


drop table #schedule

rollback tran