/*
	Add Categories to dd_scAccountCategories
	
	Note:  Assumes that no categories exist in dd_scAccountCategories
*/
set nocount on

begin tran

insert into dd_scAccountCategories (
	  CompanyId
	, DistributionCenterId
	--, CategoryId
	, CatName
	, CatShortName
	, CatDescription
	, CatActive
	, CatImported
	, [System]
)
select 1, 1, v.CategoryID, v.AcctCategory, v.AcctCategory, v.AcctCategory, 1, 0, 0
from (
	select distinct AcctCategory, row_number() over ( order by AcctCategory) as CategoryId
	from scManifestLoad_View v
	join (
		select max(CategoryId) as Id
		from dd_scAccountCategories
		) as maxId
		on 1= 1
	where acctcategory <> ''
	) as v
left join dd_scAccountCategories ac
	on v.AcctCategory = ac.CatName
where ac.CategoryID is null	
print cast(@@rowcount as nvarchar) + ' Categories Added'

rollback tran
