begin tran

declare @dbcatalog nvarchar(10)
set @dbcatalog = 'nsdb_oly'

--|Preview
	select p.ConfigurationPropertyId, p.PropertyGroup, p.PropertyName, v.PropertyValue
	from syncConfigurationProperties p
	join syncConfigurationPropertyValues v
		on p.ConfigurationPropertyId = v.ConfigurationPropertyId
	where p.PropertyGroup = 'DataExport'
	union all
	select SystemPropertyId, '', SysPropertyName, SysPropertyValue
	from syncSystemProperties
	where SysPropertyName = 'DataExportCommandArgs'
	union all 
	select p.ConfigurationPropertyId
		, p.PropertyGroup
		, p.PropertyName
		, v.PropertyValue
	from syncConfigurationProperties p
	join syncConfigurationPropertyValues v
		on p.ConfigurationPropertyId = v.ConfigurationPropertyId
	where p.PropertyName = 'ReportServer'
	union all
	select p.ConfigurationPropertyId
		, p.PropertyGroup
		, p.PropertyName
		, v.PropertyValue
	from syncConfigurationProperties p
	join syncConfigurationPropertyValues v
		on p.ConfigurationPropertyId = v.ConfigurationPropertyId
	where p.PropertyName in ( 'PDAServer', 'PDASErverPath' )

--|  Config File
	update syncConfigurationPropertyValues
		set PropertyValue = 'C:\Program Files (x86)\Syncronex\SingleCopy\DataIO\OLY\'
	from syncConfigurationProperties p
	join syncConfigurationPropertyValues v
		on p.ConfigurationPropertyId = v.ConfigurationPropertyId
	where p.PropertyName = 'DataExportConfigFile'

--|  Executable
	update syncConfigurationPropertyValues
		set PropertyValue = 'C:\Program Files (x86)\Syncronex\SingleCopy\bin\SyncExport.exe'
	from syncConfigurationProperties p
	join syncConfigurationPropertyValues v
		on p.ConfigurationPropertyId = v.ConfigurationPropertyId
	where p.PropertyName = 'DataExportEnginePath'

--|  Command Args
	update syncSystemProperties
	set SysPropertyValue = 'Forecast "C:\Program Files (x86)\Syncronex\SingleCopy\DataIO\OLY\WeeklyForecastExport.xml" /p "StartDate=01/1/1900","StopDate=01/1/1900","UserID=1" /w '
	where SysPropertyName = 'DataExportCommandArgs'

--|  Report Server URL
	update syncConfigurationPropertyValues
	set PropertyValue = 'http://localhost:80/ReportServer'
	from syncConfigurationProperties p
	join syncConfigurationPropertyValues v
		on p.ConfigurationPropertyId = v.ConfigurationPropertyId
	where p.PropertyName = 'ReportServer'

--|  PDA Server & Path
	update syncConfigurationPropertyValues
	set PropertyValue = 'mclatchy.syncronex.com'
	from syncConfigurationProperties p
	join syncConfigurationPropertyValues v
		on p.ConfigurationPropertyId = v.ConfigurationPropertyId
	where p.PropertyName = 'PDAServer'

	update syncConfigurationPropertyValues
	set PropertyValue = '/' + db_name()
	from syncConfigurationProperties p
	join syncConfigurationPropertyValues v
		on p.ConfigurationPropertyId = v.ConfigurationPropertyId
	where p.PropertyName = 'PDAServerPath'

--|  Review
	select p.ConfigurationPropertyId, p.PropertyGroup, p.PropertyName, v.PropertyValue
	from syncConfigurationProperties p
	join syncConfigurationPropertyValues v
		on p.ConfigurationPropertyId = v.ConfigurationPropertyId
	where p.PropertyGroup = 'DataExport'
	union all
	select SystemPropertyId, '', SysPropertyName, SysPropertyValue
	from syncSystemProperties
	where SysPropertyName = 'DataExportCommandArgs'
	union all 
	select p.ConfigurationPropertyId
		, p.PropertyGroup
		, p.PropertyName
		, v.PropertyValue
	from syncConfigurationProperties p
	join syncConfigurationPropertyValues v
		on p.ConfigurationPropertyId = v.ConfigurationPropertyId
	where p.PropertyName = 'ReportServer'
	union all
	select p.ConfigurationPropertyId
		, p.PropertyGroup
		, p.PropertyName
		, v.PropertyValue
	from syncConfigurationProperties p
	join syncConfigurationPropertyValues v
		on p.ConfigurationPropertyId = v.ConfigurationPropertyId
	where p.PropertyName in ( 'PDAServer', 'PDASErverPath' )

rollback tran