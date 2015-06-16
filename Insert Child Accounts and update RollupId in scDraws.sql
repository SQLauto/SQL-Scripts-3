


insert into scChildAccounts (  CompanyID, DistributionCenterID, AccountID, ChildAccountID )
select distinct 1, 1, r.RollupID as [AccountId], a.AccountID as [ChildAccountId]
from support_adhoc_import_load ld
join scAccounts a
	on ld.AcctCode = a.AcctCode
join scRollups r
	on ld.RollupCode = r.RollupCode
	
update scDraws
set RollupAcctID = ca.AccountID
from scDraws d
join scChildAccounts ca
	on ca.ChildAccountID = d.AccountID
