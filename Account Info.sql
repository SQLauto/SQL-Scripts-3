

select a.AcctCode, P.pubshortname, ua.username as [acctowner], uap.username as [apowner]
	, acctactive, ap.active
from scAccounts a
join scAccountsPubs ap
	on a.AccountID = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationID
join users ua
	on a.acctowner = ua.userid
join users uap
	on ap.apowner = uap.userid
where a.accountid = 144