

begin tran

--| assign accounts to their respective categories
select a.AccountId, a.Acctcode, at.ATName as [Account Type], ddac.CatName as [Current Category], newCat.CatName as [New Category]
into #acctCats
from scaccounts a
join dd_scAccountTypes at
	on a.AccountTypeId = at.AccountTypeId
left join scAccountsCategories ac
	on a.AccountId = ac.AccountId
join dd_scaccountcategories ddac
	on ac.CategoryId = ddac.CategoryId
join (
	select a.accountid, a.acctcode, ddac.categoryid, ddac.catname
	from scaccounts a
	join dd_scaccounttypes ddat
		on a.accounttypeid = ddat.accounttypeid
	join dd_scaccountcategories ddac
		on ddat.atname = ddac.catname
	left join scAccountsCategories ac
		on a.AccountId = ac.AccountId
		and ddac.CategoryId = ac.CategoryId
	where ac.AccountId is null
	) as newCat
on a.AccountId = newCat.AccountId
where ddac.CategoryId <> newCat.CategoryId
order by a.AcctCode


	insert into scAccountsCategories (companyid, distributioncenterid, accountid, categoryid)
	select 1, 1, a.accountid
		, ddac.categoryid
	from scaccounts a
	join dd_scaccounttypes ddat
		on a.accounttypeid = ddat.accounttypeid
	join dd_scaccountcategories ddac
		on ddat.atname = ddac.catname
	left join scAccountsCategories ac
		on a.AccountId = ac.AccountId
		and ddac.CategoryId = ac.CategoryId
	where ac.AccountId is null
	order by a.accountid
	print cast(@@rowcount as nvarchar) + ' Accounts associated with new Categories'

	delete from scaccountscategories
	where categoryid = ( select categoryid from dd_scaccountcategories where catname = 'unknown' )
	and accountid in ( 
		select accountid
		from scaccountscategories
		group by accountid
		having count(*) > 1
		)
	print cast(@@rowcount as nvarchar) + ' Accounts removed from UNKN category'

	delete scAccountsCategories
	from (
			select a.accountid
			from scaccounts a
			join scaccountscategories ac
				on a.accountid = ac.accountid
			join dd_scaccountcategories cat
				on ac.categoryid = cat.categoryid
			join dd_scaccounttypes at
				on cat.catname = at.atname
			group by a.accountid
			having count(*) > 1 ) as [eligibleAccts]
	join scaccounts a
		on eligibleAccts.accountId = a.AccountId
	join dd_scaccounttypes at
		on a.accounttypeid = at.accounttypeid
	left join scaccountscategories ac
		on a.accountid = ac.accountid
	left join dd_scaccountcategories cat
		on ac.categoryid = cat.categoryid
	where (
		cat.categoryid is null
		or at.ATName <> cat.CatName
		)
	and ATName <> 'UNKN'
	print cast(@@rowcount as nvarchar) + ' Accounts removed from category corresponding with old acct type.'

--|Review
/*
select tmp.*, ddac.CatName
from #acctCats tmp
join scAccountsCategories ac
		on tmp.AccountId = ac.AccountId
join dd_scAccountCategories ddac
	on ac.CategoryId = ddac.CategoryId	
order by tmp.AcctCode
*/

drop table #acctCats

commit tran

