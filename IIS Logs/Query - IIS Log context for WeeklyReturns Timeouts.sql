declare @timestamp datetime
declare @plusminus_minutes int

set @timestamp = '2013-09-16 10:48:01.000'
set @plusminus_minutes = 2

;with cteTimeouts as (
	select code, description
		, case when left( l.time, 2 ) < 5 then DATEADD(d, -1, l.date) else l.date end as [local_date]
		, dateadd(hour, -5, l.TIME) as [local_time]
		, CAST(
				CONVERT(varchar, 
				case when left( l.time, 2 ) < 5 then DATEADD(d, -1, l.date) else l.date end
				, 101 ) 
			+ ' ' +
			convert( varchar, dateadd(hour, -5, l.TIME), 108 ) 
		 as datetime ) as local_datetime
		, page, querystring, method, [client-ip]
	from IISLogs l
	join iis_statuscodes sc
		on l.status = sc.code
	where page like '%WeeklyReturns.asp%'
	and code <> '200'
	and querystring like '%timeout%'
	and method='POST'
	--order by [local_time]
)
, cteIISLogs as (
	select code, description
		, case when left( l.time, 2 ) < 5 then DATEADD(d, -1, l.date) else l.date end as [local_date]
		, dateadd(hour, -5, l.TIME) as [local_time]
		, CAST(
				CONVERT(varchar, 
				case when left( l.time, 2 ) < 5 then DATEADD(d, -1, l.date) else l.date end
				, 101 ) 
			+ ' ' +
			convert( varchar, dateadd(hour, -5, l.TIME), 108 ) 
		 as datetime ) as local_datetime
		, page, querystring, method, [client-ip]
	from IISLogs l
	join iis_statuscodes sc
		on l.status = sc.code
	--order by [local_time]
)
select *
from cteTimeouts t
where left( cast(local_time as time), 2) between 9 and 14
union all
select *
from cteIISLogs l
where l.local_datetime between DATEADD( minute, -1*@plusminus_minutes, @timestamp)
	and DATEADD( minute, @plusminus_minutes, @timestamp)
order by t.local_datetime


