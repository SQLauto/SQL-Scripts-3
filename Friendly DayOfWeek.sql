

select sltimestamp
	, case datepart( dw, sltimestamp )
		when 1 then 'sun'
		when 2 then 'mon'
		when 3 then 'tue'
		when 4 then 'wed'
		when 5 then 'thu'
		when 6 then 'fri'
		when 7 then 'sat'
		end as [day]
	, logmessage
from syncsystemlog
where logmessage like '%final count%'
order by 1 desc