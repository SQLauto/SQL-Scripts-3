declare @offset int
declare @drawDate datetime
declare @exportedDate datetime
declare @includeMinMaxDraw int

set @exportedDate = '1/26/2012'	--set this to view exports that occurred on a given date
set @drawDate = null		--set this to view exports that included draw from a specific date
set @includeMinMaxDraw = 0
select @offset = sysPropertyValue
from syncSystemProperties
where sysPropertyName = 'CompanyTimeOffset'

print @offset

;with cteExports 
as (
	select *
	from scDataExchangeControls ex
)
, cteExportBegin
as (
	select sltimestamp, logmessage, groupid
	from syncsystemlog
	where LogMessage like 'Data Export Started%'
	)
, cteExportEnd 
as (
select sltimestamp, logmessage, groupid
	from syncsystemlog
	where LogMessage like 'Data Export Completed%'
	or LogMessage like 'Data Export Failed%'
	or LogMessage like 'DataExport Failed%'
)
, cteLogFile
as (
	select sltimestamp, /*replace(logmessage,'Export File: ', '')*/logmessage as [ExportFile], groupid
	from syncsystemlog
	where ( LogMessage like 'Export File:%'
		or LogMessage = 'Writing one file per publication'
		)	
	)
	
select 
	convert(varchar, x.LastUpdated, 1) as [ExportDate]
	, x.LastUpdated
	, u.UserName
	, typ.ExportTypeDescription
	, case x.ExchangeStatus
		when 3 then 'SUCCESS'
		when 4 then 'FAILURE'
		end as [Status]
	, b.SLTimeStamp as [ExportStart]
	, e.SLTimeStamp	as [ExportEnd]
	, cast(
		( DATEDIFF(	SECOND
			, dateadd(hour, -1*@offset, b.sltimestamp)
			, dateadd(hour, -1*@offset, e.sltimestamp) ) / 3600 ) as varchar )
		+ 'h ' + 
		cast(
		( DATEDIFF(	SECOND
			, dateadd(hour, -1*@offset, b.sltimestamp)
			, dateadd(hour, -1*@offset, e.sltimestamp) ) % 3600 ) / 60 as varchar )
		+ 'm ' +
		cast(
		( DATEDIFF(	SECOND
			, dateadd(hour, -1*@offset, b.sltimestamp)
			, dateadd(hour, -1*@offset, e.sltimestamp) ) % 60 ) as varchar )
		+ 's ' as [Duration]
	 , f.ExportFile
	 , x.GroupId
into #exports	 		
from cteExports x
join dd_scExportTypes typ
	on x.ExchangeTypeId = typ.ExportTypeId
left join users u
	on x.UserId = u.UserId	
left join cteExportBegin b
	on x.GroupId = b.GroupId
left join cteExportEnd e
	on x.GroupId = e.GroupId
left join cteLogFile f
	on x.GroupId = f.GroupId	
where datediff(d, x.LastUpdated, @exportedDate) = 0	
order by x.LastUpdated desc	

if @includeMinMaxDraw = 1
begin
	declare @drawDate_Min datetime
	declare @drawDate_Max datetime

	select @drawDate_Min = min(ExportStart), @drawDate_Max = max(ExportEnd)
	from #exports

	;with cteDraw
	as (
		select DrawDate, RetExpDateTime, AdjExpDateTime
		from scDraws
		where DrawDate between @drawDate_Min and @drawDate_Max
	)
	select e.*
		, d.DrawDate_Min, d.DrawDate_Max
	from #exports e
	left join (
		select e.GroupId, min(d.DrawDate) as [DrawDate_Min], max(d.DrawDate) as [DrawDate_Max]
		from #exports e, cteDraw d
		where ( 
				RetExpDateTime between [exportStart] and [exportEnd]
				or AdjExpDateTime between [exportStart] and [exportEnd]
				)
		group by e.GroupId	
		) as [d]
		on e.GroupId = d.GroupId
end
else
begin
	select *
	from #exports
end

drop table #exports