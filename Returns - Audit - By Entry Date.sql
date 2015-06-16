
--|  what was "entered' today?
select p.pubshortname, SUM( cast(RetAuditValue as int))
from scDraws d
join scReturnsAudit ra
	on d.DrawID = ra.DrawId
join (
	select DrawId, MAX(ReturnsAuditId) as [maxId]
	from scReturnsAudit ra
	where datediff(d, RetAuditDate, GETDATE()) = 0
	group by DrawId
) as lastReturn
	on ra.DrawID = lastReturn.DrawId
	and ra.ReturnsAuditId = lastReturn.maxId
join nsPublications p
	on d.PublicationID = p.PublicationID	
--where RetAuditDate < '2/21/2011 16:15:39'
group by p.PubShortName	

--|  what was "entered' today?
select d.drawdate, p.pubshortname, SUM(retamount)
from scDraws d
join scReturnsAudit ra
	on d.DrawID = ra.DrawId
join (
	select DrawId, MAX(ReturnsAuditId) as [maxId]
	from scReturnsAudit ra
	where datediff(d, RetAuditDate, GETDATE()) = 0
	group by DrawId
) as lastReturn
	on ra.DrawID = lastReturn.DrawId
	and ra.ReturnsAuditId = lastReturn.maxId
join nsPublications p
	on d.PublicationID = p.PublicationID	
group by d.DrawDate, p.PubShortName	