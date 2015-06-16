begin tran

select PropertyName, PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where PropertyName = 'DataExportEnginePath'

--|multi-company, copy from existing database
--/*
update syncConfigurationPropertyValues
set PropertyValue = v2.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
join <src_db_catalog, sysinfo , nsdb>..syncConfigurationPropertyValues v2
	on v.ConfigurationPropertyValueId = v2.ConfigurationPropertyValueId
where p.PropertyName = 'DataExportEnginePath'
--*/
--|single company
/*
update syncConfigurationPropertyValues
set PropertyValue = 'C:\Progra~2\Syncronex\SingleCopy\bin\SyncExport.exe'
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where PropertyName = 'DataExportEnginePath'
*/


select PropertyName, PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where PropertyName = 'DataExportEnginePath'

<commit_or_rollback,sysinfo,rollback> tran