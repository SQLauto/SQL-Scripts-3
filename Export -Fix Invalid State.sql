begin tran

select *
from syncSystemProperties
where SysPropertyName = 'DataExportRunning'
or SysPropertyName = 'RunDataExport'

update scDataExchangeControls
set ExchangeStatus = 3
where ExchangeStatus = 1
and datediff(d, LastUpdated, GETDATE()) = 0

update syncSystemProperties
set SysPropertyValue = 'False'
where SysPropertyName = 'DataExportRunning'

--update syncSystemProperties
--set SysPropertyValue = 'True'
--where SysPropertyName = 'RunDataExport'


select *
from syncSystemProperties
where SysPropertyName = 'DataExportRunning'
or SysPropertyName = 'RunDataExport'

select *
from syncSystemProperties
where SysPropertyName like '%command%'

rollback tran