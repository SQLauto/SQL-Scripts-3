begin tran


--|  Add new category
--/*
	insert into dd_scAccountCategories ( CompanyId, DistributionCenterID, CategoryId, CatShortName, CatName, CatDescription
	, CatActive, Catimported, System 
	)
	select 1, 1
		, row_number() over ( order by category ) + 
		 (select MAX(CategoryID) from dd_scAccountCategories)
		, category
		, case Category
			when 'ScanI' then 'Scan I-control'
			when 'ScanN' then 'Scan Nexxus'
			when 'ScanW' then 'Scan Wegmans'
			when 'ScanD' then 'Scan Dollar Tree'
			end
		, N''
		, 1, 1, 0
	from (
		select distinct category
		from support_temp_scancategories
		) t
	left join dd_scAccountCategories ddac
		on t.Category = ddac.CatShortName
	where ddac.CategoryID is null		
--*/

--|  Associate Accounts with new Category
insert into scAccountsCategories (companyid, distributioncenterid, AccountId, CategoryId)
select 1, 1, a.AccountId, cat.CategoryID
	--, tmp.*
from support_temp_scancategories tmp
join scAccounts a
	on a.AcctCode = tmp.acctcode
join dd_scAccountCategories cat
	on tmp.Category = cat.CatShortName
left join scAccountsCategories ac
	on a.AccountID = ac.AccountID
	and cat.CategoryID = ac.CategoryID
where ac.CompanyID is null
--and a.AccountID is null

print 'Associated ' + cast(@@rowcount as nvarchar) + ' Accounts new category'

rollback tran