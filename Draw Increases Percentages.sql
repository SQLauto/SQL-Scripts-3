select count(*)
from scdraws
where datediff(d, drawdate, '7/15/2009') = 0

select d1.accountid, a1.acctcode, d1.publicationid, d1.drawamount, d2.drawamount
	--, ( cast(isnull(d1.drawamount,0) as decimal(5,2)) / cast(isnull(d2.drawamount,0) as decimal(5,2))) * 100 as [pct increase]
	, ( cast(d1.drawamount as decimal) / cast(d2.drawamount as decimal) ) * 100 as [pct increase]
from scdraws d1
join scdraws d2
	on d1.accountid = d2.accountid
	and d1.publicationid = d2.publicationid
join scaccounts a1
	on d1.accountid = a1.accountid
where d1.drawdate = '7/08/2009'
and d2.drawdate = '7/15/2009'
and d2.drawamount > d1.drawamount
and isnull(d2.drawamount,0) >= 0
order by d1.accountid

select avg( ( cast(d1.drawamount as decimal) / cast(d2.drawamount as decimal) ) * 100 ) as [avg pct increase]
from scdraws d1
join scdraws d2
	on d1.accountid = d2.accountid
	and d1.publicationid = d2.publicationid
join scaccounts a1
	on d1.accountid = a1.accountid
where d1.drawdate = '7/08/2009'
and d2.drawdate = '7/15/2009'
and d2.drawamount > d1.drawamount
and isnull(d2.drawamount,0) >= 0
