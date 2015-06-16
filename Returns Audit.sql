begin tran

--|  Show returns in Syncronex DB

select d.DrawDate, a.AcctCode, p.PubShortName
	, d.DrawID
	, d.DrawAmount + isnull(d.AdjAmount,0) + isnull(d.AdjAdminAmount,0) as [Draw (Net)]
	, d.RetAmount, d.RetExpDateTime, d.RetExportLastAmt
	--, d.DrawAmount, d.AdjAmount, d.AdjAdminAmount, d.RetAmount
	, ra.RetAuditDate, RetAuditValue
	, u.username
from scDraws d
left join scReturnsAudit ra
	on d.DrawID = ra.DrawId
join scAccounts a
	on d.AccountID = a.AccountID
join nsPublications p
	on d.PublicationID = p.PublicationID
join Users u
	on ra.RetAuditUserId = u.UserID
where d.DrawDate = '1/24/2011'
and a.AcctCode = '20052453'
and p.pubshortname = 'stle'

--select *
--from scDrawHistory
--where drawid = 14255604

rollback tran