
/*
insert into NSSESSION..syncSystemProperties ( [SystemPropertyId], SysPropertyName, SysPropertyDescription, SysPropertyValue, Display )
select 1, 'EnableMultiCompany', 'Enable multi company functionality', 'True', 0
union all select 2, 'ForecastServicePollingInterval', 'Polling interval in milliseconds', '1000', 0
union all select 3, 'ForecastEnginePath', 'Path to ForecastEngine.exe', 'C:\Program Files (x86)\Syncronex\SingleCopy\bin', 0
*/


update NSSESSION..syncSystemProperties
set SysPropertyValue = 'F:\Syncronex\SingleCopy\bin'
where SystemPropertyId = 3