begin tran

declare @pubCode nvarchar(5)
declare @targetDate datetime
declare @sourceDate datetime

set @pubCode = 'USP2'
set @targetDate = '9/26/2014'
set @sourceDate = '9/22/2014'

select drawdate, sum(drawamount)
from scdraws d 
join nsPublications p
	on d.PublicationID = p.PublicationID
where p.PubShortName = @pubCode
and ( d.DrawDate = @targetDate
	or d.DrawDate = @sourceDate )
group by DrawDate

;with cteSource as (
	select d.DrawID, d.AccountID, d.PublicationID, d.DrawDate, d.DrawAmount
	from scdraws d 
	join nsPublications p
		on d.PublicationID = p.PublicationID
	where p.PubShortName = @pubCode
	and ( d.DrawDate = @sourceDate )
)	
, cteTarget as (
select d.DrawID, d.AccountID, d.PublicationID, d.DrawDate, d.DrawAmount
	from scdraws d 
	join nsPublications p
		on d.PublicationID = p.PublicationID
	where p.PubShortName = @pubCode
	and ( d.DrawDate = @targetDate )
)
select src.AccountID, src.PublicationID, src.DrawID as [DrawID_Source], src.DrawDate as [DrawDate_Source], src.DrawAmount as [DrawAmount_Source], tgt.DrawID as [DrawID_Target], tgt.DrawDate as [DrawDate_Target], tgt.DrawAmount as [DrawAmount_Target]
into #draw
from cteSource src
left join cteTarget tgt
	on src.AccountID = tgt.AccountID
	and src.PublicationID = tgt.PublicationID

select *
from #draw

update scDraws
set DrawAmount = tmp.DrawAmount_Source
--select tgt.AccountID, tgt.PublicationID, tgt.DrawDate, tgt.DrawAmount, src.DrawAmount
from scDraws d
join #draw tmp
	on d.DrawID = tmp.DrawID_Target

update scDraws
set DrawAmount = 0
from scDraws d
join #draw tmp
	on d.DrawID = tmp.DrawID_Source

select drawdate, sum(drawamount)
from scdraws d 
join nsPublications p
	on d.PublicationID = p.PublicationID
where p.PubShortName = @pubCode
and ( d.DrawDate = @targetDate
	or d.DrawDate = @sourceDate )
group by DrawDate

commit tran