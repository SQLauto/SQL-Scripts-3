

select typ.ExportTypeName, typ.ExportTypeDescription
	, ex.ExchangeStatus as [ExchangeStatusId]
	, case ex.ExchangeStatus
		when -1 then 'No Status'
		when 0 then 'Not Started'
		when 1 then 'Executing'
		when 2 then 'Pending Approval'
		when 3 then 'Completed'
		else 'Unknown'
		end as [ExchangeStatus]
	, u.UserName
	, ex.CriteriaStart, ex.CriteriaStop
	, ex.LastUpdated
	, sl.LogMessage, sl.slTimestamp
from scDataExchangeControls ex
join dd_scExportTypes typ
	on ex.ExchangeTypeId = typ.ExportTypeId
left join users u
	on ex.UserId = u.UserId
join syncSystemLog sl
	on ex.GroupId = sl.GroupId
order by ex.LastUpdated desc
