/*
	ForecastEnginePath
	C:\Program Files\Syncronex\SingleCopy\bin
*/
declare @Name nvarchar(100)
declare @Value nvarchar(1000)

set @Name = 'ForecastEnginePath' 
set @Value = 'C:\Program Files (x86)\Syncronex\SingleCopy\bin'

select SystemPropertyId, SysPropertyName, SysPropertyDescription, SysPropertyValue, Display
from NSSESSION..syncSystemProperties
where SysPropertyName = @Name

update NSSESSION..syncSystemProperties
set SysPropertyValue = @Value
where SysPropertyName = @Name

select SystemPropertyId, SysPropertyName, SysPropertyDescription, SysPropertyValue, Display
from NSSESSION..syncSystemProperties
where SysPropertyName = @Name
