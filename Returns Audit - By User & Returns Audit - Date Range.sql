--|  Returns by User
select DrawDate, DrawAmount, RetAmount
	, a.AcctCode, p.PubShortName
	, UserName
	, ra.*
from scdraws d
join scReturnsAudit ra
	on d.DrawID = ra.DrawId
join scAccounts a
	on d.AccountID = a.AccountID
join nsPublications p
	on d.PublicationID = p.PublicationID
join Users u
	on RetAuditUserId = u.UserID
where U.UserName = 'jlperez@tribune.com'
and ra.RetAuditDate between '3/31/2011' and '4/3/2011'
order by DrawDate desc


--|  All Returns for a given Date Range
select u.UserName, convert(varchar, ra.RetAuditDate, 1) as [ReturnEntryDate], d.DrawDate, a.AcctCode, p.PubShortName, d.DrawAmount, ra.RetAuditValue
from scDraws d
join scReturnsAudit ra
	on d.DrawID = ra.DrawId
join Users u
	on ra.RetAuditUserId = u.UserID
join nsPublications p
	on d.PublicationID = p.PublicationID
join scAccounts a
	on d.AccountID = a.AccountID	
where d.drawdate in ('3/28/2011', '3/29/2011')
--group by u.UserName, convert(varchar, ra.RetAuditDate, 1), d.DrawDate
order by u.UserName, convert(varchar, ra.RetAuditDate, 1) desc, d.DrawDate desc