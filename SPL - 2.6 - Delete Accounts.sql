begin tran

create table #acctsToDelete (AcctCode nvarchar(25))

insert into #acctsToDelete 
select '86DEC 01'
union all select '86DEC 02'
union all select '86DEC 03'
union all select '86DEC 05'
union all select '86DEC 06'
union all select '86DEC 07'
union all select '86DEC 08'
union all select '86DEC 09'
union all select '86DEC 10'
union all select '86DEC 11'
union all select '86DEC 12'
union all select '86DEC 13'
union all select '86DEC 14'
union all select '86DEC 15'
union all select '86DEC 16'
union all select '86DEC 17'
union all select '86DEC 18'


/*
select *
from #acctsToDelete tmp
left join scAccounts a
on tmp.AcctCode = a.AcctCode
*/
print 'deleting from scDraws'
delete scDraws
from #acctsToDelete tmp
join scAccounts a
on tmp.AcctCode = a.AcctCode
join scDraws d
on a.AccountId = d.AccountId

print 'deleting from scDefaultDrawHistory'
delete scDefaultDrawHistory
from #acctsToDelete tmp
join scAccounts a
on tmp.AcctCode = a.AcctCode
join scDefaultDrawHistory d
on a.AccountId = d.AccountId

print 'deleting from scDefaultDraw'
delete scDefaultDraws
from #acctsToDelete tmp
join scAccounts a
on tmp.AcctCode = a.AcctCode
join scDefaultDraws d
on a.AccountId = d.AccountId

print 'deleting from scAccountDrops'
delete scAccountDrops
from #acctsToDelete tmp
join scAccounts a
on tmp.AcctCode = a.AcctCode
join scAccountDrops ad
on a.AccountId = ad.AccountId

print 'deleting from scAccountsCategories'
delete scAccountsCategories
from #acctsToDelete tmp
join scAccounts a
on tmp.AcctCode = a.AcctCode
join scAccountsCategories ac
on a.AccountId = ac.AccountId

print 'deleting from scAccounts'
delete scAccounts
from #acctsToDelete tmp
join scAccounts a
on tmp.AcctCode = a.AcctCode

drop table #acctsToDelete 

commit tran
