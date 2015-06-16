begin tran

declare @startdate datetime
declare @enddate datetime
declare @date datetime
declare @pubshortname nvarchar(5)

set @startdate = '6/3/2013'
set @enddate = '6/9/2013'
set @pubshortname = 'NYT'

set @date = @startdate


select drawdate, sum(drawamount)
from scdraws d 
join nsPublications p
	on d.PublicationID = p.PublicationID
join scAccountsPubs ap
	on d.AccountID = ap.AccountId
	and d.PublicationID = ap.PublicationId
where DrawDate between @startdate and @enddate
and p.PubShortName = @pubshortname 
and ap.APCustom2 = 'ZeroDraw'
group by DrawDate

select drawdate, sum(drawamount)
from scdraws d 
join nsPublications p
	on d.PublicationID = p.PublicationID
join scAccountsPubs ap
	on d.AccountID = ap.AccountId
	and d.PublicationID = ap.PublicationId
where DrawDate between dateadd(d, -7, @startdate) and dateadd(d, -7, @enddate)
and p.PubShortName = @pubshortname 
and ap.APCustom2 = 'ZeroDraw'
group by DrawDate

while @date <= @enddate
begin

	;with cteSource
	as (
		select d.*
		from scDraws d
		join nsPublications p
			on d.PublicationID = p.PublicationID
		JOIN scAccountsPubs ap
			on d.AccountID = ap.AccountId
			and d.PublicationID = ap.PublicationId
		where DrawDate = dateadd(d, -7, @date)
		and p.PubShortName = @pubshortname 
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
		where DrawDate = @date
		and p.PubShortName = @pubshortname 
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

set @date = dateadd(d, 1, @date)
end

select drawdate, sum(drawamount)
from scdraws d 
join nsPublications p
	on d.PublicationID = p.PublicationID
join scAccountsPubs ap
	on d.AccountID = ap.AccountId
	and d.PublicationID = ap.PublicationId
where DrawDate between @startdate and @enddate
and p.PubShortName = @pubshortname 
and ap.APCustom2 = 'ZeroDraw'
group by DrawDate

commit tran