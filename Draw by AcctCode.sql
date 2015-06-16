
declare @acctCode nvarchar(25)
set @acctCode = '40027415'

select a.acctcode, pubshortname, d.drawdate, d.drawamount
from scdraws d
join scaccounts a
	on d.accountid = a.accountid
join nspublications p
	on d.publicationid = p.publicationid
where a.AcctCode = @acctCode
--and d.drawdate between '7/22/2009' and '7/22/2009' 
order by d.DrawDate desc