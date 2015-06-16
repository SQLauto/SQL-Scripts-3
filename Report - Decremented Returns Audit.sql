

select d.drawdate, a.acctcode, pubshortname
	, convert(varchar, ra1.retauditdate, 0) as [Return Entry Date #1]
	, u1.username as [ReturnEntry #1 - User]
	, ra1.retauditvalue as [Return Amount #1]
	, convert(varchar, ra2.retauditdate, 0) as [Return Entry Date #2]
	, u2.username as [ReturnEntry #2 - User]
	, ra2.retauditvalue  as [Return Amount #2]
from screturnsaudit ra1
join (
	select ra.drawid, max(returnsauditid) as [maxId]
	from screturnsaudit ra
	join scdraws d
		on ra.drawid = d.drawid
	where drawdate > '10/11/2010'	
	group by ra.drawid
	having count(*) > 1
	) as multiReturns
	on ra1.drawid = multiReturns.drawid
	and ra1.returnsauditid = 1
join screturnsaudit ra2
	on ra1.drawid = ra2.drawid
	and ra2.returnsauditid = 2
join scdraws d
	on ra1.drawid = d.drawid
join scaccounts a
	on d.accountid = a.accountid
join nspublications p
	on d.publicationid = p.publicationid		
join users u1
	on ra1.retaudituserid = u1.userid
join users u2
	on ra1.retaudituserid = u2.userid
		
where ra2.retauditvalue < ra1.retauditvalue 
order by 1

