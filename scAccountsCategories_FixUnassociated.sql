set nocount on

declare @CategoryId int
declare @msg varchar(1048)
declare @count int

select @CategoryId = CategoryId
from dd_scAccountCategories
where CatShortName = 'UNKN'

select @msg = 'Found ' + cast(count(*) as varchar) + ' Accounts with zero Category associations.'
from scAccounts a
left join scAccountsCategories ac
	on a.AccountId = ac.AccountId
where ac.AccountId is null
print @msg

insert into scAccountsCategories ( CompanyId, DistributionCenterId, AccountId, CategoryId )
select 1, 1, a.AccountId, @CategoryId 
from scAccounts a
left join scAccountsCategories ac
	on a.AccountId = ac.AccountId
where ac.AccountId is null
select @msg = 'Associated ' + cast(@@rowcount as varchar) + ' Accounts with Category ''UNKN''.'
print @msg

select @msg = 'Account/Category association complete. ' + cast(count(*) as varchar) + ' remaining Accounts with zero Category associations.'
from scAccounts a
left join scAccountsCategories ac
	on a.AccountId = ac.AccountId
where ac.AccountId is null
print @msg

set nocount off
