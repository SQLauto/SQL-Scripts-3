--|scDefaultDraw Benchmarks

declare @daysBack int
set @daysBack = 30

;with cteSprocStartTimes
as (
	select row_number() over( order by SLTimeStamp desc ) as [SprocId]
		, sltimestamp as [SprocStartTime]
		, substring(LogMessage,81, len(LogMessage)) as [DeliveryDate(s)]
	from syncSystemLog
	where LogMessage = 'scManifest_Data_Load starting...'
	and SLTimeStamp > dateadd(d, -1*@daysBack, convert(varchar, getdate(),1))
)
, cteSprocEndTimes
as (
	select row_number() over( order by SLTimeStamp desc ) as [SprocId]
		, sltimestamp as [SprocEndTime]
	from syncSystemLog
	where LogMessage = 'scManifest_Data_Load completed successfully'
	and SLTimeStamp > dateadd(d, -1*@daysBack, convert(varchar, getdate(),1))
)
select s.SprocId, s.SprocStartTime, e.SprocEndTime
	, cast( DATEDIFF(	SECOND, s.SprocStartTime, e.SprocEndTime) / 3600 as varchar)
	+ 'h ' + 
	+ right('00' + cast( DATEDIFF(	SECOND, s.SprocStartTime, e.SprocEndTime) % 3600 / 60 as varchar), 2)
	+ 'm ' + 
	+ right('00' + cast( DATEDIFF(	SECOND, s.SprocStartTime, e.SprocEndTime) % 60 as varchar), 2)
	+ 's ' AS [Duration]
	, [DeliveryDate(s)]
from cteSprocStartTimes s
join cteSprocEndTimes e
	on s.SprocId = e.SprocId	
