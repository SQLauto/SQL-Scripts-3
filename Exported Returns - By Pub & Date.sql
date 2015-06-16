
select drawdate, p.pubshortname, sum(d.retamount) as [Total Returns]
	, sum( case 
		when RetExpDateTime is null then RetAmount
		else 0 end
		) as NotExported
from scdraws d
join nspublications p
	on d.publicationid = p.publicationid
join scaccounts a
	on d.accountid	= a.accountid
--join screturnsaudit ra
--	on d.drawid = ra.drawid
--join users u
--	on ra.retaudituserid = u.userid	
where pubshortname = 'gtcha'
and d.drawdate = '1/25/2014'
group by DrawDate, PubShortName
