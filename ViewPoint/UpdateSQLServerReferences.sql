use sdmconfig
set nocount on

begin tran
	declare @OldSQLServerName varchar(50),
		@NewSQLServerName varchar(50),
		@OldURL varchar(50),
		@NewURL varchar(50)
	
	select	@OldSQLServerName = '<old_sql_server_name, sysname, old_sql_server_name>',
		@NewSQLServerName = '<new_sql_server_name, sysname, new_sql_server_name>',

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
	where listsitepropertyid in (7,8)

	--|ConnectionString
	update t2k_siteproperties
	set propertyvalue = replace(propertyvalue, @OldSQLServerName , @NewSQLServerName)
	where listsitepropertyid = 7

	update t2k_siteproperties
	set propertyvalue = replace(propertyvalue, @OldSQLServerName , @NewSQLServerName)
	where listsitepropertyid = 8

	select distinct ListSitePropertyID, PropertyValue as [New T2K PropertyValue]
	from sdmconfig..t2k_siteproperties 
	where ListSitePropertyID in (7,8)

commit tran