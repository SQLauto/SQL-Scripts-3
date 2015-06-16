begin tran

select drawdate, sum(drawamount)
from scdraws d 
join nsPublications p
	on d.PublicationID = p.PublicationID
where p.PubShortName = 'wsj'
and d.DrawDate = '4/18/2013'
group by DrawDate

select drawdate, sum(drawamount)
from scdraws d 
join nsPublications p
	on d.PublicationID = p.PublicationID
where p.PubShortName = 'wsj'
and d.DrawDate = '4/25/2013'
group by DrawDate


;with cteSource
as (
	select d.*
	from scDraws d
	join nsPublications p
		on d.PublicationID = p.PublicationID
	JOIN scAccountsPubs ap
		on d.AccountID = ap.AccountId
		and d.PublicationID = ap.PublicationId
	where DrawDate = '4/18/2013'
	and p.PubShortName in ('WSJ')
	and ap.APCustom2 = 'ZeroDraw'
),
cteTarget
as (
	select d.*
	from scDraws d
	join nsPublications p
		on d.PublicationID = p.PublicationID
JOIN scAccountsPubs ap
		on d.AccountID = ap.AccountId
		and d.PublicationID = ap.PublicationId
	where DrawDate = '4/25/2013'
	and p.PubShortName in ('WSJ')
	and ap.APCustom2 = 'ZeroDraw'
)
update scDraws
set DrawAmount = src.DrawAmount
--select tgt.AccountID, tgt.PublicationID, tgt.DrawDate, tgt.DrawAmount, src.DrawAmount
from scDraws d
join cteTarget tgt
	on d.DrawID = tgt.DrawID
join cteSource src
	on src.AccountID = tgt.AccountID
	and src.PublicationID = tgt.PublicationID
	and src.DrawWeekday = tgt.DrawWeekday

select drawdate, sum(drawamount)
from scdraws d 
join nsPublications p
	on d.PublicationID = p.PublicationID
where p.PubShortName = 'wsj'
and d.DrawDate = '4/25/2013'
group by DrawDate

commit tran