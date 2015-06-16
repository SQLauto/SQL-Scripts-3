begin tran

declare @begindate datetime
declare @enddate datetime
declare @acctcode varchar(10)
declare @pubshortname varchar(5)

create table #draw (
	acctcode varchar(8)
	, DrawAmount int
	, DrawRate decimal(8,5)
	, PubShortName nvarchar(5)
)


insert into #draw
select '00005301', 2, 0.91, 'ZUSA'
union all select '00005306', 5,0.91, 'ZUSA'
union all select '00007157', 6,0.91, 'ZUSA'
union all select '00008500', 2,0.91, 'ZUSA'
union all select '00008501', 2,0.91, 'ZUSA'
union all select '00008551', 25, 0.00, 'ZUSA'
union all select '00008561', 2, 1.00, 'ZUSA'

;with cteDraw
as (
	select tmp.acctcode, tmp.PubShortName, a.AccountID, p.PublicationID	
		, d.DrawID, d.DrawAmount, d.DrawRate
		, tmp.DrawAmount as [NewDraw], tmp.DrawRate as [NewRate]
	from #draw tmp
	join scaccounts a
		on tmp.acctcode = a.acctcode
	join nsPublications p	
		on tmp.PubShortName = p.PubShortName
	left join scdraws d
		on 	a.accountid = d.accountid
		and p.PublicationID = d.PublicationID
	where d.drawdate = '11/28/2011'
)
update scDraws
set DrawAmount = cte.NewDraw
	, DrawRate = cte.NewRate
from cteDraw cte
join scDraws d
	on cte.DrawID = d.DrawID

select tmp.acctcode, tmp.PubShortName, a.AccountID, p.PublicationID	
	, d.DrawID, d.DrawAmount, d.DrawRate
	, tmp.DrawAmount as [NewDraw], tmp.DrawRate as [NewRate]
from #draw tmp
join scaccounts a
	on tmp.acctcode = a.acctcode
join nsPublications p	
	on tmp.PubShortName = p.PubShortName
left join scdraws d
	on 	a.accountid = d.accountid
	and p.PublicationID = d.PublicationID
where d.drawdate = '11/28/2011'

drop table #draw

commit tran
