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

declare @sql nvarchar(500)
declare @database nvarchar(20)
declare @accountid int
declare @companyid int
declare @begindate datetime
declare @enddate datetime
declare @acctCode nvarchar(25)
declare @diagnostic nvarchar(5)

set @begindate = '12/12/2013'
set @enddate = '12/21/2013'
set @database = 'nsdb_gre'
set @acctCode = null
set @diagnostic = 'True'

--|  Get the CompanyID
select @companyid = CompanyID
from nssession..nssessioncompanies
where CoDbCatalog = @database

--|  Get the AccountID for a specific Account
select @accountid = a.AccountID
from scAccounts a
where AcctCode = @acctCode

--|  Get the Path to ForecastEngine.exe
select @sql = '"' 
	+ replace(
		 replace(SysPropertyValue, 'Program Files (x86)', 'Progra~2' )
		 , 'Program Files', 'Progra~1' )
	+ '\ForecastEngine.exe' --'c:\Progra~2\Syncronex\SingleCopy\bin\forecastengine.exe'
from NSSESSION..syncSystemProperties
where SysPropertyName = 'ForecastEnginePath'


--set @sql = 'E:\Progra~1\Syncronex\SingleCopy\bin\forecastengine.exe'

set @sql = @sql + ' /ci ' + cast(@companyid as varchar)
if @accountid is not null
	begin
		 set @sql = @sql + ' /ac ' + cast(@accountid as varchar)
	end 
set @sql = @sql + ' /bd ' + cast(cast(@begindate as date) as varchar)
set @sql = @sql + ' /ed ' + cast(cast(@enddate as date) as varchar)
set @sql = @sql + ' /dg ' + @diagnostic + ' /ll -1"'

print @sql

exec xp_cmdshell @sql 

select SLTimeStamp, LogMessage
from syncSystemLog
where DATEDIFF(d, sltimestamp, getdate()) = 0
order by SLTimeStamp desc
