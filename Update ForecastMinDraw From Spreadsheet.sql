begin tran

select a.acctcode, p.pubshortname
	, a.AccountId, p.PublicationId, dd.drawweekday
	, dd.ForecastMinDraw
	, case drawweekday
		when 1 then Sun
		when 2 then Mon
		when 3 then Tue
		when 4 then Wed
		when 5 then Thu
		when 6 then Fri
		when 7 then Sat
		end as [New ForecastMinDraw]
into support_forecastmindraw_backup
from support_forecastmindraw tmp
join scaccounts a
	on tmp.route = a.acctcode
join nspublications p
	on tmp.[pub-edition] = p.pubshortname
join scdefaultdraws dd
	on a.accountid = dd.accountid
	and p.publicationid = dd.publicationid
order by acctcode	

update scdefaultdraws
set forecastmindraw = [new forecastmindraw]
from support_forecastmindraw_backup tmp
join scdefaultdraws dd
	on tmp.accountid = dd.accountid
	and tmp.publicationid = dd.publicationid
	and tmp.drawweekday = dd.drawweekday


commit tran