

declare @datetime datetime
set @datetime = getdate()

create table #daysofweek (
	dayofweekid int
	, dayofweekname varchar(3)
	)
insert into #daysofweek
		  select 1, 'MON'
union all select 2, 'TUE'
union all select 3, 'WED'
union all select 4, 'THU'
union all select 5, 'FRI'
union all select 6, 'SAT'
union all select 7, 'SUN'

select convert( varchar, @datetime, 1 )
	, dw1.dayofweekid
	, dw1.dayofweekname
	, dw2.dayofweekname + ' ( ' + cast(@@datefirst as varchar)+ ' )' as [datefirst]
from #daysofweek dw1
join #daysofweek dw2
	on dw2.dayofweekid = @@datefirst
where datepart(dw, @datetime) = dw1.dayofweekid

drop table #daysofweek