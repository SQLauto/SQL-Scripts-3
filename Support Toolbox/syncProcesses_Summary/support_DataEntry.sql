
declare @date datetime
set @date = '4/2/2011'


--select RetAuditDate
--from scReturnsAudit
--where datediff(d, RetAuditDate, @date) = 0
--order by 1

select dateadd(minute, -1 * datediff(minute, 0, RetAuditDate) % 15, dateadd(minute, datediff(minute, 0, RetAuditDate), 0)), count(*)
from scReturnsAudit
where datediff(d, RetAuditDate, @date) = 0
group by dateadd(minute, -1 * datediff(minute, 0, RetAuditDate) % 15, dateadd(minute, datediff(minute, 0, RetAuditDate), 0))
order by 1

select dateadd(minute, -1 * datediff(minute, 0, AdjAuditDate) % 15, dateadd(minute, datediff(minute, 0, AdjAuditDate), 0)), count(*)
from scDrawAdjustmentsAudit
where datediff(d, AdjAuditDate, @date) = 0
group by dateadd(minute, -1 * datediff(minute, 0, AdjAuditDate) % 15, dateadd(minute, datediff(minute, 0, AdjAuditDate), 0))
order by 1