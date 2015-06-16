begin tran

select d.DrawId, d.DrawDate, d.DrawWeekday, d.PublicationId, d.DrawAmount, dd.DrawAmount as [DefaultDraw]
into support_DrawUpdate_05132013
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
where datediff(d, getdate(), drawdate) > 0
and d.PublicationId in ( select PublicationId from nsPublications where PubShortName in ( 'WSJ', 'LAT', 'NYT' ) )
and a.AcctActive = 1
and ap.Active = 1
order by d.DrawDate desc, d.PublicationId

update scDraws
set DrawAmount = tmp.DefaultDraw
from support_DrawUpdate_05132013 tmp
join scDraws d
	on d.DrawId = tmp.DrawId
and d.DrawAmount <> tmp.DefaultDraw
print 'Updated ' + cast(@@rowcount as varchar) + ' Draws in scDraws.'


select d.DrawId, d.DrawDate, d.DrawWeekday, d.PublicationId, d.DrawAmount as [Draw], tmp.DrawAmount as [OldDraw], tmp.DefaultDraw
from support_DrawUpdate_05132013 tmp
join scDraws d
	on d.DrawId = tmp.DrawId
where tmp.DrawAmount <> d.DrawAmount	
order by d.DrawDate desc, d.PublicationId

commit tran