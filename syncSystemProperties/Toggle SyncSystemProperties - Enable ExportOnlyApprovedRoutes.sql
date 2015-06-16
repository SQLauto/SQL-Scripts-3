begin tran

declare @sysPropertyName nvarchar(50)
set @sysPropertyName = 'ExportOnlyApprovedRoutes'

select SysPropertyName, case SysPropertyValue when 'true' then 'Enabled' when 'false' then 'Disabled' end as [SysPropertyValue]
from syncSystemProperties
where SysPropertyName = @sysPropertyName 


update syncSystemProperties
set SysPropertyValue = case SysPropertyValue
			when 'true' then 'false'
			else 'true'
			end
	, Display = 1		
where SysPropertyName = @sysPropertyName 

select SysPropertyName, case SysPropertyValue when 'true' then 'Enabled' when 'false' then 'Disabled' end as [SysPropertyValue]
from syncSystemProperties
where SysPropertyName = @sysPropertyName 

commit tran
