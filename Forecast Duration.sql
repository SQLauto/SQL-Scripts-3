
/*

*/

begin tran

declare @counter int
declare @daysback int

declare @beginDate datetime
declare @endDate datetime

set @daysback = 7
set @beginDate = DATEADD( d, -1*@daysback, CONVERT(varchar, getdate(), 1) )
set @endDate = CONVERT(varchar, getdate(), 1) + ' 23:59:59'

select ForecastId = identity(int,1,1)
	, sltimestamp as [ForecastStartTime]
into #forecastStartTimes
from syncSystemLog
where LogMessage = 'ForecastEngine: Forecasting start'
and SLTimestamp between @beginDate and @endDate
order by SLTimeStamp desc
set @counter = @@rowcount

select ForecastId = identity(int,1,1)
	, sltimestamp as [ForecastEndTime]
into #forecastEndTimes	
from syncSystemLog
where LogMessage = 'ForecastEngine: Forecasting complete'
and SLTimestamp between @beginDate and @endDate
order by SLTimeStamp desc


select ForecastId = identity(int,1,1)
	, replace(logmessage, 'ForecastEngine: Final count: ', '') as [ForecastFinalCount]
into #forecastCounts
from syncSystemLog
where LogMessage like 'ForecastEngine: Final count: %'
and SLTimestamp between @beginDate and @endDate
order by SLTimeStamp desc

if @counter <> @@rowcount
	print 'not the same number of forecast starts as forecast ends'
else 
	print @counter

;with cteForecastResults
as (
	select s.ForecastId, s.ForecastStartTime, e.ForecastEndTime, c.ForecastFinalCount
		, datediff(second, s.ForecastStartTime, e.ForecastEndTime) as [duration]
	from #forecastStartTimes s
	join #forecastEndTimes e
		on s.ForecastId = e.ForecastId	
	left join #forecastCounts c
		on s.ForecastId = c.ForecastId
)
select *
	, cast( DATEDIFF(	SECOND, ForecastStartTime, ForecastEndTime) / 3600 as varchar)
	+ 'h ' + 
	+ cast( DATEDIFF(	SECOND, ForecastStartTime, ForecastEndTime) % 3600 / 60 as varchar)
	+ 'm ' + 
	+ cast( DATEDIFF(	SECOND, ForecastStartTime, ForecastEndTime) % 60 as varchar)
	+ 's '
from cteForecastResults	
	
--	cast(
--		( cast( DATEDIFF(	SECOND, ForecastStartTime, ForecastEndTime) as int) / 3600 ) ) as varchar 
--		+ 'h ' + 
--		--cast(
--		--( DATEDIFF(	SECOND
--		--	, ForecastStartTime
--		--	, ForecastEndTime % 3600  / 60 ) ) as varchar )
--		--+ 'm ' +
--		--cast(
--		--( DATEDIFF(	SECOND
--		--	, ForecastStartTime
--		--	, ForecastEndTime % 60 ) ) as varchar )
--		+ 's ' as [Duration]	
--from cteForecastResults	
		
rollback tran

