begin tran
/*
	This query will give you a list of the exports for a given date.  You can use the 
	exportStart and exportEnd as date parameters in the following queries
	
	select *
	from scDraws
	where RetExpDateTime between [exportStart] and [exportEnd]
	
	select *
	from scDraws
	where AdjExpDateTime between [exportStart] and [exportEnd]
		
*/
declare @date datetime
declare @offset int

set @date = null--'10/28/2010'

select @offset = sysPropertyValue
from syncSystemProperties
where sysPropertyName = 'CompanyTimeOffset'

print @offset

select ex.DataExchangeControlId
	, ex.LastUpdated
	, typ.ExportTypeDescription as [ExportType]
	, u.UserName 
	, case ex.ExchangeStatus
		when 3 then 'SUCCESS'
		when 4 then 'FAILURE'
		end as [Status]
, cast(
		( DATEDIFF(	SECOND
			, dateadd(hour, -1*@offset, sl1.sltimestamp)
			, dateadd(hour, -1*@offset, sl2.sltimestamp) ) / 3600 ) as varchar )
		+ 'h ' + 
		cast(
		( DATEDIFF(	SECOND
			, dateadd(hour, -1*@offset, sl1.sltimestamp)
			, dateadd(hour, -1*@offset, sl2.sltimestamp) ) % 3600 ) / 60 as varchar )
		+ 'm ' +
		cast(
		( DATEDIFF(	SECOND
			, dateadd(hour, -1*@offset, sl1.sltimestamp)
			, dateadd(hour, -1*@offset, sl2.sltimestamp) ) % 60 ) as varchar )
		+ 's '
	 as [Duration]
	, sl3.ExportFile
	--, sl1.sltimestamp as [exportStart]
	, dateadd(hour, -1*@offset, sl1.sltimestamp) as [exportStart (no offset)]
	--, sl2.sltimestamp as [exportEnd]
	, dateadd(hour, -1*@offset, sl2.sltimestamp) as [exportEnd (no offset)]
	
	, 'select * from scdraws where retexpdatetime between ''' + 
		convert(varchar, dateadd(hour, -1*@offset, sl1.sltimestamp), 121) + ''' and ''' + 
		convert(varchar, dateadd(hour, -1*@offset, sl2.sltimestamp), 121) + '''' as [select_ret_sql]
	, 'update scdraws set retexportlastamt = null, retexpdatetime = null where retexpdatetime between ''' + 
		convert(varchar, dateadd(hour, -1*@offset, sl1.sltimestamp), 121) + ''' and ''' + 
		convert(varchar, dateadd(hour, -1*@offset, sl2.sltimestamp), 121) + '''' as [update_ret_sql]
	, 'select * from scdraws where adjexpdatetime between ''' + 
		convert(varchar, dateadd(hour, -1*@offset, sl1.sltimestamp), 121) + ''' and ''' + 
		convert(varchar, dateadd(hour, -1*@offset, sl2.sltimestamp), 121) + '''' as [select_adj_sql]
	, 'update scdraws set adjexportlastamt = null, adjexpdatetime = null where adjexpdatetime between ''' + 
		convert(varchar, dateadd(hour, -1*@offset, sl1.sltimestamp), 121) + ''' and ''' + 
		convert(varchar, dateadd(hour, -1*@offset, sl2.sltimestamp), 121) + '''' as [update_adj_sql]
	, ex.GroupId
into #exports
from scDataExchangeControls ex
join dd_scExportTypes typ
	on ex.ExchangeTypeId = typ.ExportTypeId
left join (
	select sltimestamp, logmessage, groupid
	from syncsystemlog
	where LogMessage like 'Data Export Started%'
	) as sl1
	on ex.GroupId = sl1.GroupId
join (
	select sltimestamp, logmessage, groupid
	from syncsystemlog
	where LogMessage like 'Data Export Completed%'
	or LogMessage like 'Data Export Failed%'
	or LogMessage like 'DataExport Failed%'
	) as sl2
	on ex.GroupId = sl2.GroupId
left join (
	select sltimestamp, /*replace(logmessage,'Export File: ', '')*/logmessage as [ExportFile], groupid
	from syncsystemlog
	where LogMessage like 'Export File:%'
	) as sl3
	on ex.GroupId = sl3.GroupId	
left join users u
	on ex.UserId = u.UserId
where 
	( 
		( @date is null and ex.DataExchangeControlId > 0 )
		or ( @date is not null and datediff(d, ex.LastUpdated, @date) = 0 )
	)
	
select e.*
	, d.DrawDate_Min, d.DrawDate_Max
from #exports e
left join (
	select e.GroupId, min(d.DrawDate) as [DrawDate_Min], max(d.DrawDate) as [DrawDate_Max]
	from #exports e, scDraws d
	where ( 
			RetExpDateTime between [exportStart (no offset)] and [exportEnd (no offset)]
			or AdjExpDateTime between [exportStart (no offset)] and [exportEnd (no offset)]
			)
	group by e.GroupId	
	) as [d]
	on e.GroupId = d.GroupId
order by e.DataExchangeControlId desc
	
drop table #exports 

rollback tran	