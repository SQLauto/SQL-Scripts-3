
declare @timestamp datetime
declare @plusminus_minutes int

set @timestamp = '2013-09-16 10:48:01.000'
set @plusminus_minutes = 15

select DATEADD( minute, -1*@plusminus_minutes, @timestamp)
select DATEADD( minute, @plusminus_minutes, @timestamp)

select SLTimeStamp, LogMessage
from syncSystemLog
where SLTimeStamp between DATEADD( minute, -1*@plusminus_minutes, @timestamp)
	and DATEADD( minute, @plusminus_minutes, @timestamp)
order by SLTimeStamp