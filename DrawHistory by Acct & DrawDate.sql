select a.acctcode, pubshortname, d.drawamount, d.drawdate
	, dh.changeddate
	, fr.frname, typ.changetypedescription
	, olddraw, newdraw, dh.userid
	, frreturntargetpercent, frbasedonweeks, frexcludeexceptiondates, frdrophighlow, frignorezero, fractive, frowner
--	, a.accountid, d.publicationid
from scdraws d
join scdrawhistory dh
	on d.drawid = dh.drawid
join scaccounts a
	on d.accountid = a.accountid
join nspublications p
	on d.publicationid = p.publicationid
join dd_nschangetypes typ
	on dh.changetypeid = typ.changetypeid
join scforecastrules fr
	on dh.forecastruleid = fr.forecastruleid
where a.accountid = 5
and d.drawdate between '7/22/2009' and '7/22/2009' 
order by a.accountid, dh.changeddate desc