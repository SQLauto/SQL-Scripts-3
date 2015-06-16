

select cast(date + ' ' + dateadd(hour, -5, time) as datetime) as [logdate], page + querystring, 'iis'
from iislogs
where datediff(d, date, '8/8/2011') = 0
--and ( page like '%m233%' or querystring like '%m233%' )


union all 
select SLTimestamp, LogMessage, 'syncsystemlog'
from syncSystemLog 
where sltimestamp between '8/8/2011' and '8/8/2011 12:59:59'
--and logmessage like '%m233%'

order by 1


--delete from iislogs