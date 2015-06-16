
select changeddate, dh.changetypeid, typ.ChangeTypeDescription, UserName
from scDrawHistory dh
join (
	select drawid
	from scDrawHistory dh
	where DrawDate = '9/21/2013'
	group by drawid 
	having COUNT(*) > 1
	) prelim
	on dh.drawid = prelim.drawid
join Users u
	on dh.userid = u.UserID	
join dd_nsChangeTypes typ
	on dh.changetypeid = typ.ChangeTypeID	
where dh.changetypeid = 12



select dh.accountid, dh.publicationid, dh.olddraw, dh.newdraw 
	, changeddate, dh.changetypeid, typ.ChangeTypeDescription, UserName
from scDrawHistory dh
join (
	select drawid
	from scDrawHistory dh
	where DrawDate = '9/10/2013'
	group by drawid 
	having COUNT(*) > 1
	) prelim
	on dh.drawid = prelim.drawid
join Users u
	on dh.userid = u.UserID	
join dd_nsChangeTypes typ
	on dh.changetypeid = typ.ChangeTypeID	
--where dh.changetypeid = 12
order by dh.accountid, dh.publicationid, dh.changeddate desc