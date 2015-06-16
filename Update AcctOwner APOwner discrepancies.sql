
update ap	
	set APOwner = a.AcctOwner
from scaccounts a
join scaccountspubs ap
	on a.AccountID = ap.AccountId
join Users au
	on a.AcctOwner = au.UserID
join Users apu
	on ap.APOwner = apu.UserID
where a.AcctOwner <> ap.APOwner
and au.UserName <> 'admin@singlecopy.com'