/*
	This query updates the ReturnAmt in scDraws to that of the last value from scReturnsAudit
*/
begin tran

update scdraws
set retamount = retaudit.retauditvalue
	, retexportlastamt = null
from scdraws d
join (
	select ra.*
	from scReturnsAudit ra 
	join (
		select DrawId, Max(ReturnsAuditId) as [ReturnsAuditId]
		from screturnsaudit
		group by DrawId ) as [maxRA]
	on ra.DrawId = maxRA.DrawId
	and ra.ReturnsAuditId = maxRA.ReturnsAuditId
	) as retAudit
	on d.drawid = retAudit.drawid
where d.drawdate > '6/28/2010'
and isnull(d.retamount,0) <> retAudit.retauditvalue
and d.retamount is null

rollback tran