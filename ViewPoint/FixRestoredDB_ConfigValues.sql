use sdmconfig
set nocount on

begin tran
	declare @OldSQLServerName varchar(50),
		@NewSQLServerName varchar(50),
		@OldURL varchar(50),
		@NewURL varchar(50)
	
	select	@OldSQLServerName = 'walrus',
		@NewSQLServerName = 'SQUID',
		@OldURL = 'http://206.129.170.212/',
		@NewURL = 'http://testdemo.syncronex.com/'

--|Merc_Datasource
	select connectionstring as [Old Merc_Datasource ConnectionString]
	from sdmconfig..merc_datasource
	
	update merc_datasource
	set connectionstring = replace(connectionstring, @OldSQLServerName, @NewSQLServerName)

	select connectionstring as [New Merc_Datasource ConnectionString]
	from sdmconfig..merc_datasource
--|T2k_SiteProperties
	select distinct ListSitePropertyID, PropertyValue as [Old T2K PropertyValue] 
	from sdmconfig..t2k_siteproperties 
	where listsitepropertyid in (3,4,5,7,8)

	--|ConnectionString
	update t2k_siteproperties
	set propertyvalue = 'File Name=C:\program Files\Syncronex\ViewPoint\DB\SDMData.udl;'
	--set propertyvalue = replace(propertyvalue, @OldSQLServerName , @NewSQLServerName)
	where listsitepropertyid = 7

	update t2k_siteproperties
	set propertyvalue = 'File Name=C:\program Files\Syncronex\ViewPoint\DB\SDMConfig.udl;'
	--set propertyvalue = replace(propertyvalue, @OldSQLServerName , @NewSQLServerName)
	where listsitepropertyid = 8

	--|URL
	update t2k_siteproperties
	set propertyvalue = replace(propertyvalue, @OldURL, @NewURL)
	where listsitepropertyid = 4

	--|UNCTemplatePath
	/*
	update t2k_siteproperties
	set propertyvalue = replace(propertyvalue, 'c:\', 'd:\')
	where listsitepropertyid in (5)
	*/
	--|UNCPath
	/* 
	update t2k_siteproperties
	set propertyvalue = replace(propertyvalue, 'c:\', 'd:\')
	where listsitepropertyid in (3)
	*/
	
	select distinct ListSitePropertyID, PropertyValue as [New T2K PropertyValue]
	from sdmconfig..t2k_siteproperties 
	where ListSitePropertyID in (3,4,5,7,8)

rollback tran
--commit tran