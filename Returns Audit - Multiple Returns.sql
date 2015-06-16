
/*
	Displays Return Audit values for multiple returns
*/

select d.DrawDate, a.AcctCode, p.PubShortName, d.DrawAmount + isnull(d.AdjAmount,0) + isnull(d.AdjAdminAmount,0) as [Draw (net)]
	, d.RetAmount as [RetAmount (Current Value)]
	, ra1.RetAuditValue as [RetAmount1], ra1.RetAuditDate as [RetAmount1_EntryDate]
	, ra2.RetAuditValue as [RetAmount2], ra2.RetAuditDate as [RetAmount2_EntryDate]
	, dbo.scGetDayFrequency(d.DrawDate) as [Frequency]
into support_MultipleReturnsAudit
from scDraws d
join (
	select DrawId, min(ReturnsAuditId) as [minId],max(ReturnsAuditId) as [maxId]
	from scReturnsAudit ra
	group by DrawId
	having count(*) = 2
	) as multiReturns
	on d.DrawId = multiReturns.DrawId
join scReturnsAudit ra1
	on d.DrawID = ra1.DrawId	
	and multiReturns.minId = ra1.ReturnsAuditId
join scReturnsAudit ra2
	on d.DrawID = ra2.DrawId	
	and multiReturns.maxId = ra2.ReturnsAuditId	
join scAccounts a
	on d.AccountID = a.AccountID
join nsPublications p
	on d.PublicationID = p.PublicationID
where d.DrawAmount + isnull(d.AdjAmount,0) + isnull(d.AdjAdminAmount,0) > d.RetAmount	
order by DrawDate desc

