begin tran

select 'Multi-Company', case SysPropertyValue when 'true' then 'Enabled' when 'false' then 'Disabled' end as [SysPropertyValue]
from NSSESSION..syncSystemProperties
where SysPropertyName = 'EnableMultiCompany'


update NSSESSION..syncSystemProperties
set SysPropertyValue = case SysPropertyValue
			when 'true' then 'false'
			else 'true'
			end
where SysPropertyName = 'EnableMultiCompany'

select 'Multi-Company', case SysPropertyValue when 'true' then 'Enabled' when 'false' then 'Disabled' end as [SysPropertyValue]
from NSSESSION..syncSystemProperties
where SysPropertyName = 'EnableMultiCompany'


commit tran