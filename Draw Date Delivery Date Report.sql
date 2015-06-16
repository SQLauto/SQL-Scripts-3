

select drawdate
	, deliverydate
	, case datepart(dw, drawdate)
		when 1 then 'SUN'
		when 2 then 'MON'
		when 3 then 'TUE'
		when 4 then 'WED'
		when 5 then 'THU'
		when 6 then 'FRI'
		when 7 then 'SAT'
		end as [draw day]			
	, case datepart(dw, deliverydate)
		when 1 then 'SUN'
		when 2 then 'MON'
		when 3 then 'TUE'
		when 4 then 'WED'
		when 5 then 'THU'
		when 6 then 'FRI'
		when 7 then 'SAT'
		end  as [deliv day]			
	, pubshortname, drawamount
from scdraws d
join nspublications p
	on d.publicationid = p.publicationid
where drawdate = '12/5/2009'
and accountid = 1816584
order by drawdate desc, pubshortname
