declare @date datetime
set @date = '4/2/2012'

;with cteImportStartTimes
as (
	select row_number() over( order by SLTimeStamp desc ) as [ImportId]
		, sltimestamp as [ImportStartTime]
	from syncSystemLog
	where LogMessage = 'scManifest_Data_Load starting...'
	and datediff(d, sltimestamp, @date) = 0
)
, cteImportEndTimes
as (
	select row_number() over( order by SLTimeStamp desc ) as [ImportId]
		, sltimestamp as [ImportEndTime]
		, case LogMessage
			when 'scManifest_Data_Load completed successfully' then 'Success'
			when 'scManifest_Data_Load FAILED!  See scManifest_Data_Load.out' then 'Error'
			end as [Status]
		, LogMessage	
	from syncSystemLog
	where LogMessage in ( 'scManifest_Data_Load completed successfully', 'scManifest_Data_Load FAILED!  See scManifest_Data_Load.out')
	and datediff(d, sltimestamp, @date) = 0
)
select s.ImportId, s.ImportStartTime, e.ImportEndTime
	, cast( DATEDIFF(	SECOND, s.ImportStartTime, e.ImportEndTime) / 3600 as varchar)
	+ 'h ' + 
	+ right('00' + cast( DATEDIFF(	SECOND, s.ImportStartTime, e.ImportEndTime) % 3600 / 60 as varchar), 2)
	+ 'm ' + 
	+ right('00' + cast( DATEDIFF(	SECOND, s.ImportStartTime, e.ImportEndTime) % 60 as varchar), 2)
	+ 's ' AS [Duration]
	, e.[Status]
	, e.LogMessage
from cteImportStartTimes s
left join cteImportEndTimes e
	on s.ImportId = e.ImportId	
order by s.ImportStartTime desc