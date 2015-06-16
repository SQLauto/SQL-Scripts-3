

update syncConfigurationPropertyValues
set PropertyValue = 'C:\Program Files (x86)\Syncronex\SingleCopy\bin\SyncExport.exe'
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyName = 'DataExportEnginePath'

update syncConfigurationPropertyValues
set PropertyValue = 'C:\Program Files (x86)\Syncronex\SingleCopy\DataIO\SUN'
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyName = 'DataExportConfigFile'

select p.ConfigurationPropertyId, p.PropertyGroup, p.PropertyName, v.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyGroup like '%Export%'
