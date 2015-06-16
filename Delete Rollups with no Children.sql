begin tran

select r.RollupCode,r.RollupActive, count(ca.childaccountid) as [# of Child Accounts]
from scRollups r
left join scChildAccounts ca
	on r.RollupID = ca.AccountID
group by r.RollupCode,r.RollupActive
having count(ca.childaccountid) = 0

delete scRollups
from scRollups r
where RollupCode in (
	select RollupCode
	from scRollups r
	left join scChildAccounts ca
		on r.RollupID = ca.AccountID
	group by r.RollupCode
	having count(ca.childaccountid) = 0
	)

select r.RollupCode,r.RollupActive, count(ca.childaccountid) as [# of Child Accounts]
from scRollups r
left join scChildAccounts ca
	on r.RollupID = ca.AccountID
group by r.RollupCode,r.RollupActive
having count(ca.childaccountid) = 0
	
commit tran	