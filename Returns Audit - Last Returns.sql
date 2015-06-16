select distinct m.MfstCode, d.DrawDate, m.AcctCode, m.PubShortName, ra.RetAuditDate, ra.RetAuditValue
	, RetAmount, RetExportLastAmt
from scDraws d
join (
	select DrawId, MAX(ReturnsAuditId) as [maxId]
	from scReturnsAudit ra
	where datediff(d, RetAuditDate, '2/18/2011') = 0
	group by DrawId
) as lastReturn
	on d.DrawID = lastReturn.DrawId
join scReturnsAudit ra
	on d.DrawID = ra.DrawId
	and lastReturn.maxId = ra.ReturnsAuditId
join dbo.listMfstsAccts('Delivery', null, null, -1, 32) m
	on d.AccountID = m.AccountId
	and d.PublicationID = m.PublicationId
where datediff(d, RetAuditDate, '2/18/2011') = 0
--and RetExpDateTime is null
order by m.MfstCode, d.DrawDate, m.AcctCode
