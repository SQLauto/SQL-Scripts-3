
select
	  a.AcctCode, p.PubShortName
	, dd.AccountID, dd.PublicationID
	, dd.DrawWeekday, d.DrawDate, d.DrawAmount, dd.DrawAmount, d.DrawRate, dd.DrawRate
from scDraws d
join scDefaultDraws dd
	on d.AccountID = dd.AccountID
	and d.PublicationID = dd.PublicationID
	and d.DrawWeekday = dd.DrawWeekday
join nsPublications p
	on d.PublicationID = p.PublicationID
join scAccounts	a
	on d.AccountID = a.AccountID		
where d.DrawAmount <> dd.DrawAmount
	or d.DrawRate <> dd.DrawRate	
	
update scDraws
set DrawAmount = dd.DrawAmount
	, DrawRate = dd.DrawRate
from scDraws d
join scDefaultDraws dd
	on d.AccountID = dd.AccountID
	and d.PublicationID = dd.PublicationID
	and d.DrawWeekday = dd.DrawWeekday
join nsPublications p
	on d.PublicationID = p.PublicationID
join scAccounts	a
	on d.AccountID = a.AccountID		
where d.DrawAmount <> dd.DrawAmount
	or d.DrawRate <> dd.DrawRate		