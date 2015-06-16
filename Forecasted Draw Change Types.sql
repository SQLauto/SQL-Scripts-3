

select d.drawid, d.drawdate, d.accountid, d.publicationid, d.drawamount
	, dh.changeddate, dh.olddraw, dh.newdraw, dh.userid
	, ap.active
	, dd.*
from scdraws d
join scaccountspubs ap
	on d.accountid = ap.accountid
	and d.publicationid = ap.publicationid
join scdrawhistory dh
	on d.drawid = dh.drawid	
join dd_nschangetypes dd
	on dh.changetypeid = dd.changetypeid
where d.drawdate > getdate()
and ap.active = 0
and d.drawamount > 0
order by d.drawid


