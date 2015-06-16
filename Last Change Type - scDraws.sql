

select AcctCode, d.DrawDate, d.DrawAmount, dd.DrawAmount, typ.ChangeTypeName, typ.ChangeTypeDescription
from scAccounts a
join scDefaultDraws dd
	on a.AccountID = dd.AccountID
join scDraws d
	on dd.AccountID = d.AccountID
	and dd.PublicationID = d.PublicationID
	and dd.DrawWeekday = d.DrawWeekday
join (
	select dh.*
	from scDrawHistory dh
	join (
		select accountid, publicationid, drawdate, max(changeddate) as lastChanged
		from scDrawHistory
		where DrawDate between '1/23/13' and '2/3/13'
		group by accountid, publicationid, drawdate
		) lc
	on dh.accountid = lc.accountid
	and dh.publicationid = lc.publicationid
	and dh.drawdate = lc.drawdate
	and dh.changeddate = lc.lastChanged
) lc
	on 	d.DrawID = lc.DrawId
join dd_nsChangeTypes typ
	on lc.changetypeid = typ.ChangeTypeID	
where d.DrawDate between '1/23/13' and '2/3/13'
and AcctCode like '207576CT%'
--and ( d.DrawAmount <> 0 and dd.DrawAmount <> 0)
order by AcctCode, DrawDate