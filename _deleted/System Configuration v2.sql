begin tran

/*
	This procedure is intended to assist in setting the typical configuration 
	settings that need to be set for each installation
*/

--|  Declarations
declare @database 		nvarchar(25)
declare @ver 			nvarchar(10)
declare @doUpdate 		bit
declare @commitTran 		bit

declare @multiCompany 			nvarchar(5)
declare @webserver 			nvarchar(25)
declare @installPath_Web		nvarchar(100)
declare @installPath_SQL		nvarchar(100)
declare @dataExchangePath		nvarchar(100)

---------------------------------------------------------------------------------------------
--	MODIFY THE FOLLOWING VARIABLES AS NECESSARY
---------------------------------------------------------------------------------------------

--|  Press Ctrl + Shift + M to specify values for the following parameters
set @database = '<database_name, sysname, NSDB>'
set @installPath_Web = '<installPath_Web, sysname, C:\Program Files\Syncronex\SingleCopy>'
set @installPath_SQL = '<installPath_SQL, sysname, C:\Program Files\Syncronex\SingleCopy>'
set @dataExchangePath = '<dataExchangePath, sysname, C:\Program Files\Syncronex\SingleCopy>'
set @doUpdate = '<doUpdate, sysname, 0>'	--|  (0|1) 0 = Display current values, 1 = Display updated values
set @commitTran = '<commitTran, sysname, 0>'	--|  (0|1) 0 = Rollback, 1 = Commit

---------------------------------------------------------------------------------------------

declare @signaturePath 				nvarchar(100)
declare @deliveryReceiptsPath	 	nvarchar(100)
declare @pathToForecastEngine_exe 	nvarchar(100)
declare @pathToSyncExport_exe		nvarchar(100)
declare @sysPropertyName			nvarchar(50)
declare @sysPropertyValue			nvarchar(128)

--|  Initialize Variables
if right( @installPath_Web, 1 ) = '\'
	set @installPath_Web = left( @installPath_Web, len(@installPath_Web) - 1 )

if right( @installPath_SQL, 1 ) = '\'
	set @installPath_SQL = left( @installPath_SQL, len(@installPath_SQL) - 1 )

if right( @dataExchangePath, 1 ) = '\'
	set @dataExchangePath = left( @dataExchangePath, len(@dataExchangePath) - 1 )

--|  Get the database version
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

--select @ver as [SingleCopy Version]

set nocount on

/* Exports */

	--|  Returns/Adjustments Config
	if @doUpdate = 1
	begin  
		set @sysPropertyName = 'ExportConfigFilePath'
		select @sysPropertyValue = 
			case @ver 
				when '3.1.2.0002' then @installPath_Web + '\DataIO\' + @database + '\ExportConfig.xml'
				when '3.1.2.0004' then @installPath_Web + '\DataIO\' + @database + '\ExportConfig.xml'
				when '3.1.3.0000' then @installPath_Web + '\DataIO\' + @database
				else SysPropertyValue 
				end
		from syncSystemProperties
		where SysPropertyName = @sysPropertyName 

		update syncSystemProperties
		set SysPropertyValue = @sysPropertyValue
		where SysPropertyName = @sysPropertyName
		and SysPropertyValue <> @sysPropertyValue
		if @@rowcount > 0 
			print 'Set system property ''' + @sysPropertyName + ''' = ''' + @sysPropertyValue + ''''	
	end

	--|  Forecast Config
	if @doUpdate = 1
	begin
		set @sysPropertyName = 'DataExportConfigFile'
		select @sysPropertyValue = 
			case @ver 
				when '3.1.2.0002' then @installPath_Web + '\DataIO\' + @database + '\DailyForecastExport.xml'
				when '3.1.2.0004' then @installPath_Web + '\DataIO\' + @database + '\DailyForecastExport.xml'
				when '3.1.3.0000' then @installPath_Web + '\DataIO\' + @database
				else SysPropertyValue 
				end
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
		select @sysPropertyValue = 
			case @ver 
				when '3.1.2.0002' then @installPath_Web + '\DataIO\' + @database + '\InvoiceExportConfig.xml'
				when '3.1.2.0004' then @installPath_Web + '\DataIO\' + @database + '\InvoiceExportConfig.xml'
				when '3.1.3.0000' then @installPath_Web + '\DataIO\' + @database
				else SysPropertyValue 
				end
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

if @commitTran = 1
begin
	print 'transaction committed'
	commit tran	
end
else
begin
	print 'transaction rolled back'
	rollback tran
end

