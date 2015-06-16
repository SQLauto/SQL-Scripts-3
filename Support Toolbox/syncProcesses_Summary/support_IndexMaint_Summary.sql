
declare @date datetime
set @date = '4/2/2012'

;with cteReindexStartTimes
as (
	select row_number() over( order by SLTimeStamp desc ) as [ReindexId]
		, sltimestamp as [ReindexStartTime]
	from syncSystemLog
	where LogMessage = 'syncIndexMaintenance:  Procedure starting...'
	and datediff(d, sltimestamp, @date) = 0
)
, cteReindexEndTimes
as (
	select row_number() over( order by SLTimeStamp desc ) as [ReindexId]
		, sltimestamp as [ReindexEndTime]
	from syncSystemLog
	where LogMessage = 'syncIndexMaintenance:  Procedure completed successfully.'
	and datediff(d, sltimestamp, @date) = 0
)
select s.ReindexId, s.ReindexStartTime, e.ReindexEndTime
	, cast( DATEDIFF(	SECOND, s.ReindexStartTime, e.ReindexEndTime) / 3600 as varchar)
	+ 'h ' + 
	+ right('00' + cast( DATEDIFF(	SECOND, s.ReindexStartTime, e.ReindexEndTime) % 3600 / 60 as varchar), 2)
	+ 'm ' + 
	+ right('00' + cast( DATEDIFF(	SECOND, s.ReindexStartTime, e.ReindexEndTime) % 60 as varchar), 2)
	+ 's ' AS [Duration]
from cteReindexStartTimes s
left join cteReindexEndTimes e
	on s.ReindexId = e.ReindexId	
order by s.ReindexStartTime desc