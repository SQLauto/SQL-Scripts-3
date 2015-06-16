begin tran

--|Processing Times
select sltimestamp as [importStarted], logmessage
into #importStarted
from syncSystemLog
where LogMessage like 'Processing For%'
and SLTimeStamp < '12/16/2010'
order by SLTimeStamp desc

select pt.logmessage, pt.importStarted, min(sltimestamp) as [importCompleted]
into #importTimes
from syncSystemLog sl, #importStarted pt
where sl.LogMessage = 'Process Completed Successfully!'
and SLTimeStamp > [importStarted]
group by pt.importStarted, pt.LogMessage
order by pt.importStarted

select logmessage, importStarted, importCompleted, DATEDIFF(second, importStarted, importCompleted)
from #importTimes
where DATEDIFF(second, importStarted, importCompleted) between 1 and 10

rollback tran