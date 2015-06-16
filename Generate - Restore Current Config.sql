
--|Generate SQL Scripts to restore configuration settings

--| ForecastEnginePath
select 'use NSSESSION update nssession..syncSystemProperties 
	set SysPropertyValue = ''' + SysPropertyValue + ''' 
	where SysPropertyName = ''' + SysPropertyName + ''' 
	and SysPropertyValue <> ''' + SysPropertyValue + '''' 
from nssession..syncSystemProperties

select 'use Tacoma_SN update nssession..syncSystemProperties 
	set SysPropertyValue = ''' + SysPropertyValue + ''' 
	where SysPropertyName = ''' + SysPropertyName + ''' 
	and SysPropertyValue <> ''' + SysPropertyValue + ''''
from Tacoma_SN..syncSystemProperties
where SysPropertyValue is not null

select 'use Olympia_SN update nssession..syncSystemProperties 
	set SysPropertyValue = ''' + SysPropertyValue + ''' 
	where SysPropertyName = ''' + SysPropertyName + ''' 
	and SysPropertyValue <> ''' + SysPropertyValue + ''''
from Olympia_SN..syncSystemProperties
where SysPropertyValue is not null