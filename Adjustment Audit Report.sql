declare @drawdate datetime
declare @acctCode varchar(25)

set @drawdate = '1/1/2011'
set @acctCode = '2279054'

select d.DrawDate, d.DrawAmount, d.AdjAmount, d.AdjAdminAmount, adj.AdjAuditValue
	, d.AdjExportLastAmt
from scDrawAdjustmentsAudit adj
join (
	--|Last Owner Adjustment
	select adj.DrawId, max(drawadjustmentauditid) as [maxId]
	from scdrawadjustmentsaudit adj
	join scDraws d
		on adj.DrawId = d.DrawId
	join scAccounts a
		on adj.AccountId = a.AccountId
	where 
		( @drawDate is null and DrawAdjustmentAuditId > 0
		 or @drawDate is not null and d.DrawDate = @drawDate )
	and 
		( @acctCode is null and a.AccountId > 0
		 or @acctCode is not null and a.AcctCode = @acctCode )
	and adj.AdjAuditField = 'Carrier Adjustment'
	group by adj.DrawId
	) as lastAdj
	on adj.DrawId = lastAdj.DrawId
	and adj.DrawAdjustmentAuditId = lastAdj.maxId
join scdraws d
	on adj.DrawId = d.DrawId
where adj.AdjAuditValue <> d.AdjAmount
order by d.DrawDate desc