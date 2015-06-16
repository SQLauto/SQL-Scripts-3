
begin tran

select d.drawid, d.drawamount, d.retamount, d.adjamount, d.adjadminamount
	, d.drawamount + isnull( d.adjamount, 0) + isnull( d.adjadminamount, 0) - isnull( d.retamount, 0 ) as [net]
into #adj
from scDraws d
join nspublications p
	on d.PublicationId = p.PublicationId
where pubshortname = 'PMPOS'
and d.DrawDate = '2/18/2014'

select sum( net )
from #adj

update scDraws 
set adjadminamount = -1 * tmp.Net
from scDraws d
join #adj tmp
	on d.DrawId = tmp.DrawId

--/*
insert into scDrawAdjustmentsAudit(
		   CompanyId
		 , DistributionCenterId
		 , AccountId
		 , PublicationId
		 , DrawWeekday
		 , DrawId
		 , DrawAdjustmentAuditId
		 , AdjAuditDate
		 , AdjAuditUserId
		 , AdjAuditField
		 , AdjAuditValue
		)	
--*/		
select CompanyID
	, DistributionCenterID
	, d.AccountID
	, d.PublicationID
	, d.DrawWeekday
	, d.DrawID
	, isnull(DrawAdjustmentAuditId,0) + 1
	, GETDATE()
	, ( select userid from users where username = 'support@syncronex.com' )
	, 'Admin Amount'
	, -1 * tmp.Net
from scDraws d
join #adj tmp
	on d.DrawId = tmp.DrawId
left join (
	select DrawId, MAX(DrawAdjustmentAuditId) as DrawAdjustmentAuditId
	from scDrawAdjustmentsAudit
	group by DrawId
	) as tmpDA
on d.DrawID = tmpDA.DrawId


select sum( d.drawamount + isnull( d.adjamount, 0) + isnull( d.adjadminamount, 0) - isnull( d.retamount, 0 ) )
from scDraws d
join nspublications p
	on d.PublicationId = p.PublicationId
where pubshortname = 'PMPOS'
and d.DrawDate = '2/18/2014'

select d.drawid, d.drawamount, d.retamount, d.adjamount, d.adjadminamount
	, d.drawamount + isnull( d.adjamount, 0) + isnull( d.adjadminamount, 0) - isnull( d.retamount, 0 ) as [net]
from scDraws d
join nspublications p
	on d.PublicationId = p.PublicationId
where pubshortname = 'PMPOS'
and d.DrawDate = '2/18/2014'

commit tran