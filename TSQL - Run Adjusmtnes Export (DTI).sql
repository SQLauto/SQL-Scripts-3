/*
EXEC sp_configure 'show advanced options', 1
GO

RECONFIGURE
GO

EXEC sp_configure 'xp_cmdshell', 1
GO

RECONFIGURE
GO
*/

/*
Return "D:\Syncronex\SingleCopy\DataIO\DailyReturnsExport.xml" /p "StartDate=02/19/2014","StopDate=02/26/2014","UserID=4" /w 
*/

update scDataExchangeControls
set ExchangeStatus = 3
where ExchangeStatus = 1
and datediff(d, LastUpdated, GETDATE()) = 0

update syncSystemProperties
set SysPropertyValue = 'False'
where SysPropertyName = 'DataExportRunning'

declare @sql nvarchar(500)
declare @begindate datetime
declare @enddate datetime
declare @userid int

set @begindate = '3/23/2014'
set @enddate = '3/29/2014'

--|  Get the Path to ForecastEngine.exe
select @sql = '' 
	+ replace(
		 replace(PropertyValue, 'Program Files (x86)', 'Progra~2' )
		 , 'Program Files', 'Progra~1' )
	--+ '\SyncExport.exe'
from syncConfigurationProperties p
join syncConfigurationPropertyValues v
	on p.ConfigurationPropertyId = v.ConfigurationPropertyId
where PropertyName = 'DataExportEnginePath'

print @sql

select @userid = ISNULL(UserID,1)
from Users
where UserName = 'support@syncronex.com'

set @sql = @sql + ' Custom "D:\Syncronex\SingleCopy\DataIO\CustomAdjustmentsExport_DTI.xml" /p "StartDate=' + convert(varchar, cast(@begindate as date),1) + '","StopDate=' + convert(varchar, cast(@enddate as date), 1) + '","UserID=' + cast(@userid as varchar) + '" '

print @sql

exec xp_cmdshell @sql 

--select SLTimeStamp, LogMessage
--from syncSystemLog
--where DATEDIFF(d, sltimestamp, getdate()) = 0
--order by SLTimeStamp desc
