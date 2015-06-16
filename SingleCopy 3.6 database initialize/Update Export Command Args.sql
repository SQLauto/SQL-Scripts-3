
update syncSystemProperties
set SysPropertyValue = 'Forecast "C:\Program Files (x86)\Syncronex\SingleCopy\DataIO\WeeklyForecastExport.xml" /p "StartDate=01/01/1999","StopDate=01/01/1999","UserID=3" /w '
where SysPropertyName = 'DataExportCommandArgs'