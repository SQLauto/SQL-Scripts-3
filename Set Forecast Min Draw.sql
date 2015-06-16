begin tran

select a.AccountId, ap.PublicationId 
	, AcctCode, typ.ATName, PubShortName
	, drawweekday
	, case DrawWeekDay
		when 1 then 'Sun'
		when 2 then 'Mon'
		when 3 then 'Tue'
		when 4 then 'Wed'
		when 5 then 'Thu'
		when 6 then 'Fri'
		when 7 then 'Sat'
		end as [day]
	, convert(varchar, ap.DeliveryStopDate, 1) + ' - ' + convert(varchar, ap.DeliveryStartDate, 1) as [DeliveryStopRange]
	, dd.DrawAmount as [DefaultDraw]
	, dd.ForecastMinDraw
--	, acctactive as [acct active]	
--	, ap.active as [pub active]
into support_Backup_scDefaultDraws_04072011
from scAccounts a
join dd_scAccountTypes typ
	on a.AccountTypeId = typ.AccountTypeId
join scaccountspubs ap
	on a.accountid = ap.accountid
join nspublications p
	on ap.publicationid = p.publicationid
join scdefaultdraws dd
	on ap.accountid = dd.accountid
	and ap.publicationid = dd.publicationid
where atname = 'rack'
and pubshortname = 'GZ'
--and drawweekday not in (1, 7)
and active = 1
and acctactive = 1
--and drawamount < 3
order by acctcode, drawweekday

update scdefaultdraws
set forecastmindraw = 2
from scAccounts a
join dd_scAccountTypes typ
	on a.AccountTypeId = typ.AccountTypeId
join scaccountspubs ap
	on a.accountid = ap.accountid
join nspublications p
	on ap.publicationid = p.publicationid
join scdefaultdraws dd
	on ap.accountid = dd.accountid
	and ap.publicationid = dd.publicationid
where atname = 'rack'
and pubshortname = 'GZ'
--and drawweekday not in (1, 7)
and dd.DrawAmount > 0
and active = 1
and acctactive = 1

select tmp.*, dd.forecastmindraw as [forecast min draw (new)]
from scdefaultdraws dd
join support_Backup_scDefaultDraws_04072011 tmp
	on dd.accountid = tmp.accountid
	and dd.publicationid = tmp.publicationid
	and dd.drawweekday = tmp.drawweekday

commit tran