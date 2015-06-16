begin tran

select COUNT(*)
from scAccounts a
join scAccountsPubs ap
	on a.AccountID = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationID	
join dd_scAccountTypes at
	on a.AccountTypeID = at.AccountTypeID
where ATName = 'Rack'	
and ExcludeFromBilling = 1

select a.AcctCode, at.ATName, p.PubShortName, ap.ExcludeFromBilling
from scAccounts a
join scAccountsPubs ap
	on a.AccountID = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationID	
join dd_scAccountTypes at
	on a.AccountTypeID = at.AccountTypeID
where ATName = 'Rack'	

update scAccountsPubs
set ExcludeFromBilling = 1
from scAccounts a
join scAccountsPubs ap
	on a.AccountID = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationID	
join dd_scAccountTypes at
	on a.AccountTypeID = at.AccountTypeID
where ATName = 'Rack'	
and ExcludeFromBilling = 0

select COUNT(*)
from scAccounts a
join scAccountsPubs ap
	on a.AccountID = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationID	
join dd_scAccountTypes at
	on a.AccountTypeID = at.AccountTypeID
where ATName = 'Rack'	
and ExcludeFromBilling = 1

commit tran