/*
	verify paths
*/

select SystemPropertyId, SysPropertyName, SysPropertyValue
from nssession..syncSystemProperties
where SysPropertyName = 'ForecastEnginePath'

--update nssession..syncSystemProperties
--set SysPropertyValue = 'C:\Program Files\Syncronex\SingleCopy\bin'
--where SysPropertyName = 'ForecastEnginePath'

/*
select *
from syncSystemProperties
where SysPropertyName like '%export%'
*/

select p.ConfigurationPropertyId, p.PropertyGroup, p.PropertyName, v.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyGroup = 'DataExport'

update syncConfigurationPropertyValues
	set PropertyValue = 'C:\Program Files\Syncronex\SingleCopy\bin\SyncExport.exe'
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyName = 'DataExportEnginePath'

update syncConfigurationPropertyValues
	set PropertyValue = 'C:\Program Files\Syncronex\SingleCopy\DataIO\nsdb_sdut'
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyName = 'DataExportConfigFile'
