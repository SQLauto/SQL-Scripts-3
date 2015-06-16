;with cte as (
	select RetAuditDate
	from scReturnsAudit
	where datediff(d, RetAuditDate, getdate()) = 0
)
select 
    RetAuditDate = dateadd(hour,datediff(hh,0,RetAuditDate) + 1,0),
    rows = count(1)
 from cte
 group by dateadd(hour,datediff(hh,0,RetAuditDate)+1,0)
 order by 1 desc