

select dh.*, typ.*
from scaccounts a
join scdraws d
	on a.accountid = d.accountid
join scdrawhistory dh
	on d.drawid = dh.drawid
join dd_nschangetypes typ
	on dh.changetypeid = typ.changetypeid
where a.acctcode = '0516193S'
and d.drawdate = '6/19/2010'
and d.publicationid = 3