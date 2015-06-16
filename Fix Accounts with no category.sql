
begin tran

insert into scAccountsCategories (CompanyID, DistributionCenterID, AccountID, CategoryID)
select 1, 1, AccountID, 0
from scAccounts a
where a.AccountID not in (
	select AccountID
	from scAccountsCategories
	)
rollback tran	