

select DrawAmount, RetAmount
	, UserName
	, ra.*
	
from scdraws d
join scReturnsAudit ra
	on d.DrawID = ra.DrawId
join scAccounts a
	on d.AccountID = a.AccountID
join nsPublications p
	on d.PublicationID = p.PublicationID
join Users u
	on RetAuditUserId = u.UserID
where a.AcctCode = '40019805'
and p.PubShortName = 'hoy'
and d.DrawDate = '9/14/2010'

