

select a.accountid, a.acctcode, d.publicationid, pubshortname, d.drawdate, d.drawamount
	, typ.changetypedescription
	, dh.changeddate, olddraw, newdraw, dh.userid
	, fr.frname, frreturntargetpercent, frbasedonweeks, frexcludeexceptiondates, frdrophighlow, frignorezero, fractive, frowner
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
where pubshortname = 'gaz'
and d.drawweekday = datepart(dw, '7/22/2009')
and d.drawdate between dateadd(d, -42, '7/22/2009') and '7/22/2009' 
and a.accountid = 1
order by a.accountid, d.drawdate desc