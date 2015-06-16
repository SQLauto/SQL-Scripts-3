

begin tran

select typ.ExportTypeDescription
	, dd.*
	, ex.LastUpdated
	, ex.DataExchangeControlID	
from scDataExchangeControls ex
join dd_scProcessingStates dd
	on ex.ExchangeStatus = dd.ProcessingStateId
join dd_scExportTypes typ
	on ex.ExchangeTypeId = typ.ExportTypeId	
and datediff(d, ex.LastUpdated, GETDATE()) = 0
order by ex.LastUpdated desc

--select *
--from dd_scProcessingStates

update scDataExchangeControls
set ExchangeStatus = 7  --|7=cancelled
where ExchangeStatus = 1  --|1=pending
and datediff(d, LastUpdated, GETDATE()) = 0

/*
update syncSystemProperties
set SysPropertyValue = 'False'
where SysPropertyName = 'DataExportRunning'

update syncSystemProperties
set SysPropertyValue = 'True'
where SysPropertyName = 'RunDataExport'


select *
from syncSystemProperties
where SysPropertyName = 'DataExportRunning'
or SysPropertyName = 'RunDataExport'

select *
from syncSystemProperties
where SysPropertyName like '%command%'
*/

select typ.ExportTypeDescription
	, dd.*
	, ex.LastUpdated
	, ex.DataExchangeControlID	
from scDataExchangeControls ex
join dd_scProcessingStates dd
	on ex.ExchangeStatus = dd.ProcessingStateId
join dd_scExportTypes typ
	on ex.ExchangeTypeId = typ.ExportTypeId	
and datediff(d, ex.LastUpdated, GETDATE()) = 0	
order by ex.LastUpdated desc

commit tran