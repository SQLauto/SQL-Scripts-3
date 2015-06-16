begin tran

declare @cnt int
declare @msg nvarchar(1024)

declare @maxId int
select @maxId = max(CategoryId) + 1
from dd_scAccountCategories

--|  Add new category
insert into dd_scAccountCategories ( CompanyId, DistributionCenterID, CategoryId, CatShortName, CatName, CatDescription
	, CatActive, Catimported, System 
	)
select 1, 1
	, @maxId
	, '411'
	, '411'
	, 'Category added on '  + convert(varchar, getdate(), 1)
	, 1, 1, 0

--|  Associate Accounts with new Category
insert into scAccountsCategories (companyid, distributioncenterid, AccountId, CategoryId)
select 1, 1, AccountId, @maxId
from scAccounts
where AcctActive = 1

set @msg = 'Associated ' + cast(@@rowcount as nvarchar) + ' Accounts new category'
print @msg
--exec nsSystemLog_Insert 2, 0, @msg

rollback tran