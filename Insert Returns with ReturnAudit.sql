begin tran

update scDraws
	set RetAmount = tmp.RetAuditValue 
from scDraws d
join support..scReturnsAudit_SUN tmp
	on d.DrawID = tmp.DrawId	
where d.RetAmount <> tmp.RetAuditValue
	
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
select d.CompanyID
	, d.DistributionCenterID
	, d.AccountID
	, d.PublicationID
	, d.DrawWeekday
	, d.DrawID
	, isnull(tmp.ReturnsAuditId,0) + 1
	, GETDATE()
	, ( select userid from users where username = 'support@syncronex.com' )
	, 'Return Amount'
	, tmp.RetAuditValue
from scDraws d
join support..scReturnsAudit_SUN tmp
	on d.DrawID = tmp.DrawId	
left join (
	select DrawId, MAX(ReturnsAuditId) as [ReturnsAuditId]
	from scReturnsAudit
	group by DrawId
	) as tmpRA
on d.DrawID = tmpRA.DrawId
where d.RetAmount <> tmp.RetAuditValue

rollback tran