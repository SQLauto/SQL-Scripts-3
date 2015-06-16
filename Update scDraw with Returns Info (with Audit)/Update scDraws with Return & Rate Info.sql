
begin tran
--|
update tmpReturnsImport
set DrawId = d.DrawID
	, AccountId = a.AccountID
	, PublicationId = p.PublicationID
	, AcctCode = right('00000000' + tmp.AcctCode, 8)
from tmpReturnsImport tmp
left join scAccounts a
	on right('00000000' + tmp.AcctCode, 8) = a.AcctCode
left join nsPublications p
	on tmp.Pub = p.PubShortName
left join scDraws d
	on a.AccountID = d.AccountID
	and p.PublicationID = d.PublicationID
	and tmp.DrawDate = d.DrawDate


update scDraws
	set RetAmount = tmp.RetAmount 
		, DrawRate = tmp.DrawRate
from tmpReturnsImport tmp
join scDraws d
	on tmp.DrawId = d.DrawID
	
insert into scReturnsAudit (
		   CompanyId
		 , DistributionCenterId
		 , AccountId
		 , PublicationId
		 , DrawWeekday
		 , DrawId
		 , ReturnsAuditId
		 , RetAuditDate
		 , RetAuditUserId
		 , RetAuditField
		 , RetAuditValue
		)	
select CompanyID
	, DistributionCenterID
	, d.AccountID
	, d.PublicationID
	, d.DrawWeekday
	, d.DrawID
	, isnull(ReturnsAuditId,0) + 1
	, GETDATE()
	, 3
	, 'Return Amount'
	, tmp.RetAmount
from tmpReturnsImport tmp
join scDraws d
	on tmp.DrawId = d.DrawID
left join (
	select DrawId, MAX(ReturnsAuditId) as [ReturnsAuditId]
	from scReturnsAudit
	group by DrawId
	) as tmpRA
on d.DrawID = tmpRA.DrawId

commit tran
