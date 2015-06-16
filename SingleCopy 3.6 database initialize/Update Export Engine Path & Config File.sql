
select p.ConfigurationPropertyId, p.PropertyGroup, p.PropertyName, v.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyGroup = 'DataExport'


update syncConfigurationPropertyValues
	set PropertyValue = 'E:\Program Files (x86)\Syncronex\SingleCopy\DataIO\Export_tul\'
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyName = 'DataExportConfigFile'

update syncConfigurationPropertyValues
	set PropertyValue = 'E:\Program Files (x86)\Syncronex\SingleCopy\bin\SyncExport.exe'
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyName = 'DataExportEnginePath'


select p.ConfigurationPropertyId, p.PropertyGroup, p.PropertyName, v.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where p.PropertyGroup = 'DataExport'
