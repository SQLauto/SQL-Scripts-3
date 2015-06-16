

select 
	  a.AcctCode, pubshortname as [Pub]
	, convert(nvarchar, LastNonZeroDrawDate, 101) as [LastNonZeroDrawDate]
	--, convert(nvarchar, dateadd(d, -7, convert(varchar, getdate(), 1)), 101) as [threshold]
	--, d.AccountID, d.PublicationID
	
from scaccounts a
join scdraws d
	on d.accountid = a.accountid
join (
	select accountid, publicationid, max(drawdate) as [LastNonZeroDrawDate]
	from scdraws
	where drawamount > 0
	group by accountid, publicationid
	) as lastNonZeroDraw
	on d.accountid = lastNonZeroDraw.accountid
	and d.publicationid = lastNonZeroDraw.publicationid
	and d.drawdate = lastNonZeroDraw.lastNonZeroDrawDate
join nspublications p
	on d.publicationid = p.publicationid
where lastNonZeroDrawDate < dateadd(d, -7, convert(varchar, getdate(), 1))
order by cast(LastNonZeroDrawDate as datetime) desc