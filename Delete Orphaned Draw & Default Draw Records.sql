begin tran

delete dh
from scdrawhistory dh
join scDraws d
	on d.drawid = dh.drawid
left join scAccountsPubs ap
	on d.AccountID = ap.AccountId
	and d.PublicationID = ap.PublicationId
join scAccounts a
	on d.AccountID = a.AccountID	
join nsPublications p
	on d.PublicationID = p.PublicationID	
where ap.AccountPubID is null

delete d
from scDraws d
left join scAccountsPubs ap
	on d.AccountID = ap.AccountId
	and d.PublicationID = ap.PublicationId
join scAccounts a
	on d.AccountID = a.AccountID	
join nsPublications p
	on d.PublicationID = p.PublicationID	
where ap.AccountPubID is null

delete d
from scDefaultDraws d
left join scAccountsPubs ap
	on d.AccountID = ap.AccountId
	and d.PublicationID = ap.PublicationId
join scAccounts a
	on d.AccountID = a.AccountID	
join nsPublications p
	on d.PublicationID = p.PublicationID	
where ap.AccountPubID is null

commit tran