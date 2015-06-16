begin tran

declare @start datetime
declare @stop datetime
	set @start = '7/7/2011'
declare @firstday int

set @stop = DATEADD(d, 6, @start)
set @firstday = DATEPART(DW, @start)

declare @sql nvarchar(4000)

create table #draw (
	Zip nvarchar(15)
	, Pub nvarchar(5)
	, [Net0] int
	, [Net1] int
	, [Net2] int
	, [Net3] int
	, [Net4] int
	, [Net5] int
	, [Net6] int
)
	
;with cteDraw
as (
	select	
		  AcctPostalCode	AS ZIP
		, PubShortName		AS PUB
		, CASE WHEN D.DrawWeekday = ( @firstday + 0 ) % 7 + 1 THEN D.DrawAmount + isnull(d.AdjAmount,0)+ isnull(d.AdjAdminAmount,0) + ISNULL(d.RetAmount,0) ELSE NULL END as [Net0]
		, CASE WHEN D.DrawWeekday = ( @firstday + 1 ) % 7 + 1 THEN D.DrawAmount ELSE NULL END as [Net1]
		, CASE WHEN D.DrawWeekday = ( @firstday + 2 ) % 7 + 1 THEN D.DrawAmount ELSE NULL END as [Net2]
		, CASE WHEN D.DrawWeekday = ( @firstday + 3 ) % 7 + 1 THEN D.DrawAmount ELSE NULL END as [Net3]
		, CASE WHEN D.DrawWeekday = ( @firstday + 4 ) % 7 + 1 THEN D.DrawAmount ELSE NULL END as [Net4]
		, CASE WHEN D.DrawWeekday = ( @firstday + 5 ) % 7 + 1 THEN D.DrawAmount ELSE NULL END as [Net5]
		, CASE WHEN D.DrawWeekday = ( @firstday + 6 ) % 7 + 1 THEN D.DrawAmount ELSE NULL END as [Net6]
	from scDraws d
	join scAccounts a
		on d.AccountID = a.AccountID
	join nsPublications p
		on d.PublicationID = p.PublicationID
	where d.DrawDate between @start AND @stop
)
insert into #draw
select Zip, PUB
	, sum( Net0 )
	, sum( Net1 )
	, sum( Net2 )
	, sum( Net3 )
	, sum( Net4 )
	, sum( Net5 )
	, sum( Net6 )
from cteDraw
group by ZIP, PUB
order by ZIP

set @sql = 
'select Zip, Pub'
	+ ', Net0 as [' + CONVERT(varchar, @start,1)  + ']'
	+ ', Net1 as [' + CONVERT(varchar, dateadd(d, 1, @start),1)  + ']'
	+ ', Net2 as [' + CONVERT(varchar, dateadd(d, 2, @start),1)  + ']'
	+ ', Net3 as [' + CONVERT(varchar, dateadd(d, 3, @start),1)  + ']'
	+ ', Net4 as [' + CONVERT(varchar, dateadd(d, 4, @start),1)  + ']'
	+ ', Net5 as [' + CONVERT(varchar, dateadd(d, 5, @start),1)  + ']'
	+ ', Net6 as [' + CONVERT(varchar, dateadd(d, 6, @start),1)  + ']'
	+ ' from #draw'

exec (@sql)

drop table #draw
