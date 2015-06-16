begin tran

declare @sysPropertyName nvarchar(50)
set @sysPropertyName = '%salesperiod%'

select SysPropertyName
	, SysPropertyValue
from syncSystemProperties
where SysPropertyName like @sysPropertyName 

update syncSystemProperties
set SysPropertyName = case 
			when left(SysPropertyName,1) = '_' then right(SysPropertyName, len(SysPropertyName)-1) 
			else '_' + SysPropertyName
			end
where SysPropertyName like @sysPropertyName 

select SysPropertyName
	, SysPropertyValue
from syncSystemProperties
where SysPropertyName like @sysPropertyName 

commit tran
