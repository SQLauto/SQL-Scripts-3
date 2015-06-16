begin tran

select *
from scdataexchangecontrols

update scdraws
set adjexpdatetime = null
	, adjexportlastamt = null
where datediff(d, adjexpdatetime, getdate()) = 0

select drawdate, adjexpdatetime, isnull(adjamount,0) + isnull(adjadminamount,0), adjexportlastamt
from scdraws
where datediff(d, adjexpdatetime, getdate()) = 0
and isnull(adjamount,0) + isnull(adjadminamount,0) <> adjexportlastamt

rollback tran