begin tran

select d.DrawId, d.DrawDate, d.DrawWeekday, d.PublicationId, d.DrawAmount, dd.DrawAmount as [DefaultDraw]
into support_scDraws_PG_05182011
from scDraws d
join scDefaultDraws dd
	on d.DrawWeekday = dd.Drawweekday
	and d.PublicationId = dd.PublicationId
	and d.AccountId = dd.AccountId
join scAccountsPubs ap
	on dd.AccountId = ap.AccountId
	and dd.PublicationId = ap.PublicationId
join scAccounts a
	on dd.AccountId = a.AccountId
where ( 
	d.drawdate = '5/11/2011'
	or d.drawdate = '5/18/2011' 
)
and d.PublicationId = ( select PublicationId from nsPublications where PubShortName = 'PG' )
and a.AcctActive = 1
and ap.Active = 1
order by d.DrawDate desc, d.PublicationId

update scDraws
set DrawAmount = tmp.DefaultDraw
from support_scDraws_PG_05182011 tmp
join scDraws d
	on d.DrawId = tmp.DrawId
and d.DrawAmount <> tmp.DefaultDraw
print 'Updated ' + cast(@@rowcount as varchar) + ' Rates in scDraws.'


select d.DrawId, d.DrawDate, d.DrawWeekday, d.PublicationId, d.DrawAmount as [NewDraw], tmp.DrawAmount, tmp.DefaultDraw
from support_scDraws_PG_05182011 tmp
join scDraws d
	on d.DrawId = tmp.DrawId
order by d.DrawDate desc, d.PublicationId

commit tran