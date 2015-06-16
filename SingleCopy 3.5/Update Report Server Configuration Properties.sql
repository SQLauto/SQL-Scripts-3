

update syncConfigurationPropertyValues
set PropertyValue = 'http://ajc-dd-msqlrps.coxnewsajc.int/ReportServer'
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyName = 'ReportServer'

select p.ConfigurationPropertyId, p.PropertyGroup, p.PropertyName, v.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyGroup like '%Report%'



update syncSystemProperties
set SysPropertyValue = 'true'
where SysPropertyName = 'EnableEnhancedReporting'

select *
from syncSystemProperties
where SysPropertyName = 'EnableEnhancedReporting'