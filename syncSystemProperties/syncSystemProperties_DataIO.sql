begin tran

/*
	Sets the DataIO path in syncSystemProperties.  In version 3.1.3, paths to the export config 
	files should not include the file name.

	Use Ctrl+Shift+M to specify values for the parameters before executing 

*/

--|  Declarations
declare @ver 			nvarchar(10)
declare @doUpdate 		bit
declare @commitTran 	bit
declare @dataIO_Path	nvarchar(100)

declare @sysPropertyName nvarchar(50)
declare @sysPropertyValue nvarchar(128)

---------------------------------------------------------------------------------------------
--|  Press Ctrl + Shift + M to specify values for the following parameters
---------------------------------------------------------------------------------------------
set @dataIO_Path = '<dataIO_Path, sysname, C:\Program Files\Syncronex\SingleCopy\DataIO>'
set @doUpdate = '<doUpdate, sysname, 1>'	--|  (0|1) 0 = Display current values, 1 = Display updated values
set @commitTran = '<commitTran, sysname, 0>'	--|  (0|1) 0 = Rollback, 1 = Commit
---------------------------------------------------------------------------------------------

--|Check the version.  For use with database version 3.1.3 or higher
select @ver = replace(verInfoVersion, 'Core_', '')
from nsversioninfo v1
join (
	select max(verInfoId) as verInfoId
	from nsversionInfo
	where verInfoDescription in (
		'Core Installation'
		, 'Core Upgrade'
		)
	) as v2
on v1.verInfoId = v2.verInfoId

if ( left( @ver, 5 ) <> '3.1.3' )
begin
	print 'Database is not the correct version.  Database must be version 3.1.3 or higher.'
	goto rollbackTran
end
else
begin
	set nocount on

	/* Exports */

		--|  Path to Returns/Adjustments Configuration (xml) file
		if @doUpdate = 1
		begin  
			set @sysPropertyName = 'ExportConfigFilePath'
			select @sysPropertyValue = @dataIO_Path
			from syncSystemProperties
			where SysPropertyName = @sysPropertyName 

			update syncSystemProperties
			set SysPropertyValue = @sysPropertyValue
			where SysPropertyName = @sysPropertyName
			and SysPropertyValue <> @sysPropertyValue
			if @@rowcount > 0 
				print 'Set system property ''' + @sysPropertyName + ''' = ''' + @sysPropertyValue + ''''	
		end

		--|  Path to Forecast Configuration (xml) file
		if @doUpdate = 1
		begin
			set @sysPropertyName = 'DataExportConfigFile'
			select @sysPropertyValue = @dataIO_Path
			from syncSystemProperties
			where SysPropertyName = @sysPropertyName 

			update syncSystemProperties
			set SysPropertyValue = @sysPropertyValue
			where SysPropertyName = @sysPropertyName
			and SysPropertyValue <> @sysPropertyValue
			if @@rowcount > 0 
				print 'Set system property ''' + @sysPropertyName + ''' = ''' + @sysPropertyValue + ''''
		end

		--|  Invoices Config
		if @doUpdate = 1
		begin
			set @sysPropertyName = 'InvoiceExportConfigFilePath'
			select @sysPropertyValue = @dataIO_Path
			from syncSystemProperties
			where SysPropertyName = @sysPropertyName 

			update syncSystemProperties
			set SysPropertyValue = @sysPropertyValue
			where SysPropertyName = @sysPropertyName
			and SysPropertyValue <> @sysPropertyValue
			if @@rowcount > 0 
				print 'Set system property ''' + @sysPropertyName + ''' = ''' + @sysPropertyValue + ''''

		end

	--|  Review System Configuration Settings
		select 'ExportConfigFilePath (Returns/Adjustments)' as SysPropertyName, SysPropertyValue
		from syncSystemProperties
		where SysPropertyName in ( 'ExportConfigFilePath' )
		union all
		select 'DataExportConfigFile (Forecast)' as SysPropertyName, SysPropertyValue
		from syncSystemProperties
		where SysPropertyName in ( 'DataExportConfigFile' )
		union all
		select 'ExportConfigFilePath (Invoice)' as SysPropertyName, SysPropertyValue
		from syncSystemProperties
		where SysPropertyName in ( 'InvoiceExportConfigFilePath' )
	end

	if @commitTran = 1
	begin
		goto commitTran
	end
	else
	begin
		goto rollbackTran
	end
return

commitTran:
	print 'Transaction committed'
	commit tran	
	return

rollbackTran:
	print 'Transaction rolled back'
	rollback tran
	return


