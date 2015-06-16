

select acctcode, pubshortname
, case DrawWeekDay
		when 1 then 'Sun'
		when 2 then 'Mon'
		when 3 then 'Tue'
		when 4 then 'Wed'
		when 5 then 'Thu'
		when 6 then 'Fri'
		when 7 then 'Sat'
		end as [day]
	, forecastmindraw, forecastmaxdraw
from scaccounts a
join scdefaultdraws dd
	on a.accountid = dd.accountid
join nspublications p
	on dd.publicationid = p.publicationid
where forecastmindraw > 0
or forecastmaxdraw < 2147483647
order by acctcode, pubshortname
