

;with cteDraws
as (
	select *
	from scdraws d
	where d.drawdate between '3/18/2012' and dateadd(d, -13, '6/8/2012')
	and retamount <> retexportlastamt
), cteLastReturn
as (
	select d.DrawId, max(ra.RetAuditDate) as [RetAuditDate]
	from cteDraws d
	join scReturnsAudit ra
		on d.DrawId = ra.DrawId
	group by d.DrawId	
), cteLastAdjustment
as (
	select d.DrawId, max(da.AdjAuditDate) as [AdjAuditDate]
	from cteDraws d
	join scDrawAdjustmentsAudit da
		on d.DrawId = da.DrawId
	group by d.DrawId	
)

select a.AcctCode, p.PubShortName, d.DrawDate, d.DrawAmount, d.RetAmount, d.RetExportLastAmt, d.RetExpDateTime, r.RetAuditDate as [Last Return Entry]
	, isnull(d.AdjAmount, 0) + isnull(d.AdjAdminAmount,0) as [AdjAmount], d.AdjExportLastAmt, d.AdjExpDateTime, da.AdjAuditDate as [Last Adjustment]
from cteDraws d
left join cteLastReturn r
	on d.DrawId = r.DrawId
left join cteLastAdjustment da
	on d.DrawId = da.DrawId	
join scAccounts a
	on a.AccountId = d.AccountId
join nsPublications p
	on d.PublicationId = p.PublicationId	
where (
	( datediff(d, r.RetAuditDate, d.RetExpDateTime) = 0
	 and datepart(hh, r.RetAuditDate) = 0 )
	or
	( datediff(d, da.AdjAuditDate, d.AdjExpDateTime) = 0
	 and datepart(hh, da.AdjAuditDate) = 0
	 )
	)
order by DrawDate Desc, Acctcode, PubShortName	