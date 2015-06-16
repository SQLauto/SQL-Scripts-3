

declare @begindate datetime
declare @enddate datetime

set @begindate = dateadd(month, -1, convert(varchar, getdate(), 1))
set @enddate = convert(varchar, getdate(), 1)

print @begindate
print @enddate

select a.acctcode, p.pubshortname, convert(varchar, @begindate, 1) + ' - ' + convert(varchar, @enddate, 1) as [Zero Draw]
	, a.acctactive, active as [acctpubactive]
from scdraws d
join scaccounts a
	on d.accountid = a.accountid
join nspublications p
	on d.publicationid = p.publicationid
join scaccountspubs ap
	on a.accountid = ap.accountid
	and p.publicationid = ap.publicationid	
where drawdate between @begindate and @enddate
group by a.acctcode, p.pubshortname, a.acctactive, active 
having sum(drawamount) = 0
order by acctcode, pubshortname