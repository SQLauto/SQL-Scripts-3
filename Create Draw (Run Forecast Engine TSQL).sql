

declare @sql nvarchar(500)
declare @database nvarchar(20)
declare @accountid int
declare @companyid int
declare @begindate datetime
declare @enddate datetime
declare @account nvarchar(25)
declare @diagnostic nvarchar(5) 

--02/20/2014 for account 1740086?
set @begindate = '4/4/2014'
set @enddate = '4/13/2014'
set @database = 'nsdb_advor'
set @account = '1720042'
set @diagnostic = 'False'  

--

--

select @accountid = a.AccountID
from scAccounts a
where AcctCode = @account

select p.PubShortName, d.DrawDate, DrawAmount
from scDraws d
join nsPublications p
	on d.PublicationID = p.PublicationID
where AccountID = @accountid
and d.DrawDate between @begindate and @enddate
order by d.DrawDate

select @companyid = CompanyID
from nssession..nssessioncompanies
where CoDbCatalog = @database

set @sql = 'c:\Progra~2\Syncronex\SingleCopy\bin\forecastengine.exe'
set @sql = @sql + ' /ci ' + cast(@companyid as varchar)
set @sql = @sql + ' /ac ' + cast(@accountid as varchar)
set @sql = @sql + ' /bd ' + cast(cast(@begindate as date) as varchar)
set @sql = @sql + ' /ed ' + cast(cast(@enddate as date) as varchar)
set @sql = @sql + ' /dg ' + @diagnostic + ' /ll -1"'

exec xp_cmdshell @sql 

select p.PubShortName, d.DrawDate, DrawAmount
from scDraws d
join nsPublications p
	on d.PublicationID = p.PublicationID
where AccountID = @accountid
and d.DrawDate between @begindate and @enddate
order by d.DrawDate

--group by PubShortName

--select SLTimeStamp, LogMessage
--from syncSystemLog
--where DATEDIFF(d, sltimestamp, getdate()) = 0
--and LogMessage like 'ForecastEngine%'
--order by SLTimeStamp desc