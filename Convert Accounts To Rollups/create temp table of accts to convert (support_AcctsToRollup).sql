select a.*
into support_AcctsToRollup
from scAccounts a
join dd_scAccountTypes typ
	on a.AccountTypeID = typ.AccountTypeID
where typ.ATName = 'RA'