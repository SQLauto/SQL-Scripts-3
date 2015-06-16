

select a.AcctCode, p.PubShortName
	, a.AcctActive, a.AcctImported, a.*
	, dd.*
from scdefaultdraws dd
left join scAccountsPubs ap
	on dd.AccountID = ap.AccountId
	and dd.PublicationID = ap.PublicationId
join nsPublications p
	on dd.PublicationID = p.PublicationID	
join scAccounts a
	on dd.AccountID = a.AccountID	
where ap.AccountPubID is null

