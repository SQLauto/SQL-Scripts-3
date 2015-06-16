
;with cteLog
as (
select SLTimeStamp, LogMessage
	, substring(LogMessage, len('Processing for ') + 2, 8) as [raw rundate]
	, cast(substring(LogMessage, len('Processing for ') + 2, 8) as datetime) as [RunDate]
	, cast(convert(varchar, sltimestamp, 1) as datetime) as [ProcessingDate]
from syncSystemLog
where LogMessage like '%processing for%'
--order by SLTimeStamp desc
)
select *, datediff(d, RunDate, ProcessingDate)
from cteLog
where datediff(d, RunDate, ProcessingDate) > 1
order by SLTimeStamp desc