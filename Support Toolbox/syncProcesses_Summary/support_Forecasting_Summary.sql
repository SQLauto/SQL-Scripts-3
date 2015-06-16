declare @date datetime
set @date = '4/2/2012'

	;with cteForecastStartTimes
	as (
		select row_number() over( order by SLTimeStamp desc ) as [ForecastId]
			, sltimestamp as [ForecastStartTime]
		from syncSystemLog
		where LogMessage = 'ForecastEngine: Forecasting start'
		and datediff(d, sltimestamp, @date) = 0
	)
	, cteForecastEndTimes
	as (
		select row_number() over( order by SLTimeStamp desc ) as [ForecastId]
			, sltimestamp as [ForecastEndTime]
		from syncSystemLog
		where LogMessage = 'ForecastEngine: Forecasting start'
		and datediff(d, sltimestamp, @date) = 0
	)
	, cteForecastFinalCount
	as (
		select row_number() over( order by SLTimeStamp desc ) as [ForecastId]
			, replace(logmessage, 'ForecastEngine: Final count: ', '') as [ForecastFinalCount]
		from syncSystemLog
		where LogMessage like 'ForecastEngine: Final count: %'
		and datediff(d, sltimestamp, @date) = 0
	) 
	select s.ForecastId, s.ForecastStartTime, e.ForecastEndTime, c.ForecastFinalCount
		, cast( DATEDIFF(	SECOND, s.ForecastStartTime, e.ForecastEndTime) / 3600 as varchar)
		+ 'h ' + 
		+ right('00' + cast( DATEDIFF(	SECOND, s.ForecastStartTime, e.ForecastEndTime) % 3600 / 60 as varchar), 2)
		+ 'm ' + 
		+ right('00' + cast( DATEDIFF(	SECOND, s.ForecastStartTime, e.ForecastEndTime) % 60 as varchar), 2)
		+ 's ' AS [Duration]
	from cteForecastStartTimes s
	left join cteForecastEndTimes e
		on s.ForecastId = e.ForecastId	
	left join cteForecastFinalCount c
		on s.ForecastId = c.ForecastId
