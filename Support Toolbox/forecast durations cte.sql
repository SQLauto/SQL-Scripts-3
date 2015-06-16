
declare @daysBack int
set @daysBack = 7

;with cteForecastStartTimes
as (
	select row_number() over( order by SLTimeStamp desc ) as [ForecastId]
		, sltimestamp as [ForecastStartTime]
	from syncSystemLog
	where LogMessage = 'ForecastEngine: Forecasting start'
	and SLTimeStamp > dateadd(d, -1*@daysBack, convert(varchar, getdate(),1))
)
, cteForecastEndTimes
as (
	select row_number() over( order by SLTimeStamp desc ) as [ForecastId]
		, sltimestamp as [ForecastEndTime]
	from syncSystemLog
	where LogMessage = 'ForecastEngine: Forecasting start'
	and SLTimeStamp > dateadd(d, -1*@daysBack, convert(varchar, getdate(),1))
)
, cteForecastFinalCount
as (
	select row_number() over( order by SLTimeStamp desc ) as [ForecastId]
		, replace(logmessage, 'ForecastEngine: Final count: ', '') as [ForecastFinalCount]
	from syncSystemLog
	where LogMessage like 'ForecastEngine: Final count: %'
	and SLTimeStamp > dateadd(d, -1*@daysBack, convert(varchar, getdate(),1))
) 
select s.ForecastId, s.ForecastStartTime, e.ForecastEndTime, c.ForecastFinalCount
	, cast( DATEDIFF(	SECOND, s.ForecastStartTime, e.ForecastEndTime) / 3600 as varchar)
	+ 'h ' + 
	+ right('00' + cast( DATEDIFF(	SECOND, s.ForecastStartTime, e.ForecastEndTime) % 3600 / 60 as varchar), 2)
	+ 'm ' + 
	+ right('00' + cast( DATEDIFF(	SECOND, s.ForecastStartTime, e.ForecastEndTime) % 60 as varchar), 2)
	+ 's ' AS [Duration]
from cteForecastStartTimes s
join cteForecastEndTimes e
	on s.ForecastId = e.ForecastId	
left join cteForecastFinalCount c
	on s.ForecastId = c.ForecastId