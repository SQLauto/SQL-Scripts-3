begin tran

declare @begindate datetime
declare @enddate datetime
declare @acctcode nvarchar(25)

set @begindate = '6/8/2013'
select @enddate = max(drawdate)
from scDraws

set @acctcode = '009580'

select d.DrawId, d.DrawDate, d.DrawWeekday, d.PublicationId, d.DrawRate
	, dd.DrawRate
from scDraws d
join scDefaultDraws dd
	on d.DrawWeekday = dd.Drawweekday
	and d.PublicationId = dd.PublicationId
	and d.AccountId = dd.AccountId
where d.drawdate between @begindate and @enddate
and d.Accountid in (
	select accountid
	from scaccounts
	where acctcode in ( @acctcode )
	)
and d.DrawRate <> dd.DrawRate
order by d.DrawDate desc, d.PublicationId

update scDraws
set DrawRate = dd.DrawRate
from scDraws d
join scDefaultDraws dd
	on d.DrawWeekday = dd.Drawweekday
	and d.PublicationId = dd.PublicationId
	and d.AccountId = dd.AccountId
where d.drawdate between @begindate and @enddate
and d.Accountid in (
	select accountid
	from scaccounts
	where acctcode in ( @acctcode )
	)
and d.DrawRate <> dd.DrawRate
print 'Updated ' + cast(@@rowcount as varchar) + ' Rates in scDraws.'


select d.DrawId, d.DrawDate, d.DrawWeekday, d.PublicationId, d.DrawRate
	, dd.DrawRate
from scDraws d
join scDefaultDraws dd
	on d.DrawWeekday = dd.Drawweekday
	and d.PublicationId = dd.PublicationId
	and d.AccountId = dd.AccountId
where d.drawdate between @begindate and @enddate
and d.Accountid in (
	select accountid
	from scaccounts
	where acctcode in ( @acctcode )
	)
and d.DrawRate <> dd.DrawRate
order by d.DrawDate desc, d.PublicationId


commit tran