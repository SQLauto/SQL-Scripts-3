
select max( [distinct ret audit users] ) as [Max distinct ret audit users]
from (
	select DrawId, count(*) as [distinct ret audit users]
	from (
		select DrawId, RetAuditUserId
		from scReturnsAudit ra
		group by DrawId, RetAuditUserId
		) as tmp
	group by DrawId
	) as retAuditUsers
	

