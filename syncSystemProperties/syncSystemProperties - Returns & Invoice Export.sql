begin tran

--|  Previous Values
select SystemPropertyId, SysPropertyName, SysPropertyDescription, SysPropertyValue, Display
from syncSystemProperties
where SysPropertyName in (
	  'ExportConfigFilePath'		--| Returns export config file
	, 'InvoiceExportConfigFilePath'	--| Invoice export config file
	)

--|  Update
update syncSystemProperties
set SysPropertyValue = case SysPropertyName
	when 'ExportConfigFilePath' then 'C:\Program Files\Syncronex\SingleCopy\DataIO\ExportConfig.xml'
	when 'InvoiceExportConfigFilePath' then 'C:\Program Files\Syncronex\SingleCopy\DataIO\InvoiceExportConfig.xml'
	else SysPropertyValue
	end
	, Display = case SysPropertyName
	when 'DataExportConfigFile' then 1
	when 'DataExportEnginePath' then 1
	else Display
	end

--|  New Values
select SystemPropertyId, SysPropertyName, SysPropertyDescription, SysPropertyValue, Display
from syncSystemProperties
where SysPropertyName in (
	  'ExportConfigFilePath' --|DailyForecastExport.xml or WeeklyForecastExport.xml
	, 'InvoiceExportConfigFilePath' --|Full path to SyncExport.exe
	)

commit tran
