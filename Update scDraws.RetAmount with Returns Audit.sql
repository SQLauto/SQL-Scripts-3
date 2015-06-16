
begin tran


update scDraws 
set RetAmount = ld.Returns
from scDraws d
join scAccounts a
	on d.AccountID = a.AccountID
join nsPublications p
	on d.PublicationID = p.PublicationID
join supportManifestLoad ld
	on ld.RouteNo = a.AcctCode
	and ld.Publication = p.PubName
	and ld.DrawDate = d.DrawDate

		
declare @userid int
select @userid = UserId
from Users 
where UserName = 'support@syncronex.com'
	
insert into scReturnsAudit ( CompanyId, DistributionCenterId, AccountId, PublicationId, DrawWeekday, DrawId, ReturnsAuditId, RetAuditDate, RetAuditUserId, RetAuditField, RetAuditValue )
select d.CompanyId, d.DistributionCenterId, d.AccountId, d.PublicationId, d.DrawWeekday, d.DrawId, 1, d.DrawDate, @userid, 'Return Amount', isnull(ld.Returns,0)
from scDraws d
join scAccounts a
	on d.AccountID = a.AccountID
join nsPublications p
	on d.PublicationID = p.PublicationID
join supportManifestLoad ld
	on ld.RouteNo = a.AcctCode
	and ld.Publication = p.PubName
	and ld.DrawDate = d.DrawDate
	
commit tran	