/*
	DataExportEnginePath
	C:\Program Files\Syncronex\SingleCopy\bin\SyncExport.exe
*/
declare @Name nvarchar(100)
declare @Value nvarchar(1000)

set @Name = 'DataExportEnginePath' 
set @Value = 'C:\Program Files (x86)\Syncronex\SingleCopy\bin\SyncExport.exe'

select p.PropertyName, v.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where PropertyName = @Name


update syncConfigurationPropertyValues
set PropertyValue = @Value
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where PropertyName = @Name

select p.PropertyName, v.PropertyValue
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where PropertyName = @Name
