declare @drawdate datetime

set @drawdate = '12/22/2011'

;with cteLastDrawChange
as (
	select dh.*
	from scDrawHistory dh
	join (
		select drawid, MAX(changeddate) as changeddate
		from scDrawHistory
		where DATEDIFF(d, drawdate, @drawdate) = 0
		group by drawid
		) lastchange
	on dh.drawid = lastchange.drawid
	and dh.changeddate = lastchange.changeddate
) 
select d.DrawID 
	, a.AcctCode, p.PubShortName, d.DrawDate, d.DrawAmount [Draw (current]
	, typ.ChangeTypeDescription, dh.changeddate
	, dh.olddraw, dh.newdraw
from scDraws d
join cteLastDrawChange dh
	on d.DrawID = dh.drawid
join scAccounts a
	on d.AccountID = a.AccountID	
join nsPublications p
	on d.PublicationID = p.PublicationID	
join dd_nsChangeTypes typ
	on dh.changetypeid = typ.ChangeTypeID	
where d.DrawDate = @drawdate
and a.AcctActive = 1
and typ.ChangeTypeDescription <> 'Data was changed in response to a Circulation System Import'