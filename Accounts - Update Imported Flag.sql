
;with cteImported
as (
	select RollupCode as [AcctCode], 'Rollup' as [Type], null as [AccountType], RollupImported as [Imported], RollupActive as [Active]
	from scRollups
	union all
	select AcctCode, 'Child', typ.ATName, AcctImported, AcctActive
	from scAccounts a
	join scChildAccounts ca
		on a.AccountID = ca.ChildAccountID
	join dd_scAccountTypes typ
		on typ.AccountTypeID = a.AccountTypeID	
	union all
	select AcctCode, 'Stand-Alone', typ.ATName , AcctImported, AcctActive
	from scAccounts a
	left join scChildAccounts ca
		on a.AccountID = ca.ChildAccountID
	join dd_scAccountTypes typ
		on typ.AccountTypeID = a.AccountTypeID	
	where ca.AccountID is null	
--order by 1
) 
update scAccounts
set AcctImported = case i.AccountType 
	when 'Child' then 0
	when 'Stand-Alone' then 1
	else i.Imported
	end
from scAccounts a
join cteImported i
	on a.AcctCode = i.AcctCode