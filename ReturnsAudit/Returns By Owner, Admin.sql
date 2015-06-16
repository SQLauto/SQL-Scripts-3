select *
into #mfsts
from dbo.listMfstsAccts('Delivery',null, null, -1, null);

with returnsAduit_Owner ( MfstCode, AcctCode, PubShortName, DrawId, DrawDate, DrawAmount, [Owner], [Returns] )
as
(
	select m.MfstCode, a.AcctCode, p.PubShortName, ra.DrawId, d.DrawDate, d.DrawAmount, u.UserName as [Owner], sum( cast(ra.RetAuditValue as int)) as [Returns]
	from scReturnsAudit ra
	join scAccounts a
		on ra.AccountId = a.AccountId
	join scDraws d
		on ra.DrawId = d.DrawId
	join nsPublications p
		on ra.PublicationId = p.PublicationId
	join #mfsts m
		on d.AccountId = m.AccountId
		and d.PublicationId = m.PublicationId
		and dbo.scGetDayFrequency(d.DrawDate) & m.Frequency > 0		
	join Users u
		on ra.RetAuditUserId = u.UserId
	where ra.RetAuditUserId = m.ManifestOwner
	and datediff(d, RetAuditDate, getdate()) < 7
	group by m.MfstCode, a.AcctCode, p.PubShortName, ra.DrawId, d.DrawDate, d.DrawAmount, u.UserName
)
,returnsAduit_Admin ( MfstCode, AcctCode, PubShortName, DrawId, DrawDate, DrawAmount, [Returns] )
as
(
	select m.MfstCode, a.AcctCode, p.PubShortName, ra.DrawId, d.DrawDate, d.DrawAmount, sum( cast(ra.RetAuditValue as int)) as [Returns]
	from scReturnsAudit ra
	join scAccounts a
		on ra.AccountId = a.AccountId
	join scDraws d
		on ra.DrawId = d.DrawId
	join nsPublications p
		on ra.PublicationId = p.PublicationId
	join #mfsts m
		on d.AccountId = m.AccountId
		and d.PublicationId = m.PublicationId
		and dbo.scGetDayFrequency(d.DrawDate) & m.Frequency > 0		
	join Users u
		on ra.RetAuditUserId = u.UserId
	where ra.RetAuditUserId <> m.ManifestOwner
	and datediff(d, RetAuditDate, getdate()) < 7
	group by m.MfstCode, a.AcctCode, p.PubShortName, ra.DrawId, d.DrawDate, d.DrawAmount
)

select
	  coalesce( oa.MfstCode, aa.MfstCode) as [MfstCode]  
	, coalesce( oa.AcctCode, aa.AcctCode) as [AcctCode]
	, coalesce( oa.PubShortName, aa.PubShortName) as [PubShortName]
	, coalesce( oa.DrawDate, aa.DrawDate) as [DrawDate]
	, coalesce( oa.DrawAmount, aa.DrawAmount) as [DrawAmount]
	, oa.[Owner]
	, oa.[Returns] as [OwnerReturns]
	--, aa.UserName as [AdminUserName]
	, aa.[Returns] as [AdminReturns]
from returnsAduit_Owner oa
full outer join returnsAduit_Admin aa
	on oa.DrawId = aa.DrawId
order by 1, 3, 2

drop table #mfsts