begin tran
/*
Route 0941000 - Argus Counter Sales W/Inserts - New Parent G0940028
 
Route 0941008 - Argus Counter Sales W/Out Inserts - New Parent G0940170
*/

create table #tmp (acctcode nvarchar(25), parent nvarchar(25))
insert into #tmp
select 
 '0941000','G0940028'
union all select '0941008','G0940170'

select *
from scAccounts a
join #tmp tmp
	on a.AcctCode = tmp.acctcode
	
select *
from scRollups r
join #tmp tmp	
	on r.RollupCode = tmp.parent

delete scChildAccounts
from #tmp tmp
join scAccounts a
	on tmp.acctcode = a.AcctCode
left join scChildAccounts ca
	on a.AccountID = ca.ChildAccountID

insert into scChildAccounts (CompanyID, DistributionCenterID, AccountID, ChildAccountID)
select 1, 1, r.RollupId, a.accountid
from #tmp tmp
join scAccounts a
	on tmp.acctcode = a.AcctCode
join scRollups r
	on tmp.parent = r.RollupCode

--select *
--from scRollups
--where RollupCode = '101999'

drop table #tmp

commit tran