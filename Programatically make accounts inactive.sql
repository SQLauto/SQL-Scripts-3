begin tran

select a.AcctCode, a.AccountID
from support_AcctsToDeactivate tmp
join scAccounts a
	on tmp.AcctCode = a.AcctCode
join scAccountsPubs ap
	on a.AccountID = ap.AccountId	
	

update scAccountsPubs
set Active = 0
from support_AcctsToDeactivate tmp
join scAccounts a
	on tmp.AcctCode = a.AcctCode
join scAccountsPubs ap
	on a.AccountID = ap.AccountId	
where ap.Active = 1
print cast(@@rowcount as varchar) + ' scAccountsPubs records deactivated'	

update scAccounts
set AcctActive = 0
	, AcctOwner = ( 
		select userid from Users where UserName = 'inactive@ajc.com' 
		)
from support_AcctsToDeactivate tmp
join scAccounts a
	on tmp.AcctCode = a.AcctCode
where a.AcctActive = 1	
print cast(@@rowcount as varchar) + ' scAccounts records deactivated'	

delete msi
from support_AcctsToDeactivate tmp
join scAccounts a
	on tmp.AcctCode = a.AcctCode
join scAccountsPubs ap
	on a.AccountID = ap.AccountId	
join scManifestSequenceItems msi
	on ap.AccountPubID = msi.AccountPubId
print cast(@@rowcount as varchar) + ' records removed from scManifestSequenceItems'

commit tran