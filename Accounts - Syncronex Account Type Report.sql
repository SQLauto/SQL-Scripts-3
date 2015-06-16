
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