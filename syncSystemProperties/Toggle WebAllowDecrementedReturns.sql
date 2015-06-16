begin tran

declare @sysPropertyName nvarchar(50)
set @sysPropertyName = 'WebAllowDecrementedReturns'

select SysPropertyName, case SysPropertyValue when 'true' then 'True' when 'false' then 'False' end as [SysPropertyValue]
from syncSystemProperties
where SysPropertyName = @sysPropertyName 


update syncSystemProperties
set SysPropertyValue = case SysPropertyValue
			when 'true' then 'false'
			else 'true'
			end
where SysPropertyName = @sysPropertyName 

select SysPropertyName, case SysPropertyValue when 'true' then 'True' when 'false' then 'False' end as [SysPropertyValue]
from syncSystemProperties
where SysPropertyName = @sysPropertyName 

commit tran
