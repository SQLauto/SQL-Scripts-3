declare @drawdate datetime
set @drawdate = '1/22/2013'


select min(dh.changeddate), max(dh.changeddate)
from scDrawHistory dh
join (
	select drawid, max(changeddate) as [lastchanged]
	from scDrawHistory
	where datediff(d, drawdate, @drawdate) = 0
	group by drawid
	) lc
	on dh.drawid = lc.drawid
join scDraws d
	on dh.drawid = d.DrawID