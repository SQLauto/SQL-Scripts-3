/*
	Add Categories to dd_scAccountCategories
	
	Note:  Assumes that no categories exist in dd_scAccountCategories
*/
set nocount on

select distinct AcctCategory
into #cats
from scManifestLoad_View
where acctcategory <> ''

alter table #cats add CategoryId int identity(1,1)
go

begin tran

insert into dd_scAccountCategories (
	  CompanyId
	, DistributionCenterId
	, CategoryId
	, CatName
	, CatShortName
	, CatDescription
	, CatActive
	, CatImported
	, [System]
)
select 1, 1, CategoryId, AcctCategory, AcctCategory, AcctCategory, 1, 0, 0
from #cats
print cast(@@rowcount as nvarchar) + ' Categories Added'

select *
from dd_scAccountCategories

rollback tran

drop table #cats

