
select typ.ChangeTypeDescription,AcctCode, PubShortName, dh.DrawHistoryDate
	, dh.DrawHistOldRate, dh.DrawHistNewRate
	, dh.DrawHistOldDraw, dh.DrawHistNewDraw
from scDefaultDrawHistory dh
join (
	select a.AccountID, p.PublicationID, a.AcctCode, p.PubShortName
	from scdefaultdrawhistory dh
	join scAccounts a
		on dh.AccountID = a.AccountID
	join nsPublications p
		on dh.PublicationID = p.PublicationID
	where ( DrawHistOldRate = 0.00
		and DrawHistNewRate = 1.35 )
	and DrawHistoryDate > '9/1/2013'
	) prelim
on dh.AccountID = prelim.AccountID
and dh.PublicationID = prelim.PublicationID
join dd_nsChangeTypes typ
	on dh.ChangeTypeID = typ.ChangeTypeID
where dh.DrawHistOldRate <> dh.DrawHistNewRate	
order by dh.AccountID, dh.DrawHistoryDate desc