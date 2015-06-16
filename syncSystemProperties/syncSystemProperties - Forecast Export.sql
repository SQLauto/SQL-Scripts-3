begin tran

--|syncSystemProperties:  Forecast Export 

--|  Previous Values
select SystemPropertyId, SysPropertyName, SysPropertyDescription, SysPropertyValue, Display
from syncSystemProperties
where SysPropertyName in (
	  'DataExportConfigFile' --|DailyForecastExport.xml or WeeklyForecastExport.xml
	, 'DataExportEnginePath' --|Full path to SyncExport.exe
	)

--|  Update
update syncSystemProperties
set SysPropertyValue = case SysPropertyName
	when 'DataExportConfigFile' then 'C:\Program Files\Syncronex\SingleCopy\DataIO\nsdb'
--	when 'DataExportEnginePath' then 'C:\Program Files\Syncronex\SingleCopy\bin\SyncExport.exe'
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
	  'DataExportConfigFile' --|DailyForecastExport.xml or WeeklyForecastExport.xml
	, 'DataExportEnginePath' --|Full path to SyncExport.exe
	)
union all
select SystemPropertyId, SysPropertyName, SysPropertyDescription, SysPropertyValue, Display
from syncSystemProperties
where SysPropertyName in (
	  'DataExportCommandArgs'
	, 'RunDataExport'
	, 'DataExportRunning'
	, 'ExportServicePollingInterval'
	)
order by 1

commit tran