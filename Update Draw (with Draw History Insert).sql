begin tran

declare @changeddate datetime
declare @userId int

set @changeddate = '1/17/2013'
select @userId = UserId
from Users
where UserName = 'support@syncronex.com'
if @@rowcount = 0
	set @userId = 1

print @userId
	
select d.*
--into #tmpDraws
into support_scDraws_Pub14_01172013
from scdraws d
join nspublications p
	on d.publicationid = p.publicationid
where drawdate > '1/15/2013'
and pubshortname like '%14%'
and d.drawamount > 0

update scDraws
set DrawAmount = 0
from scDraws d
--join #tmpDraws tmp
join support_scDraws_Pub14_01172013 tmp
	on d.DrawId = tmp.DrawId


insert into scDrawHistory ( companyid, distributioncenterid, accountid, publicationid, drawid, drawweekday
	, changeddate, drawdate, olddraw, newdraw, oldrate, newrate, olddeliverydate, newdeliverydate, changetypeid, userid )

select d.companyid, d.distributioncenterid, d.accountid, d.publicationid, d.drawid, d.drawweekday
	, @changeddate, d.drawdate, d.drawamount, 0 as [newdraw], d.drawrate, d.drawrate 
	, d.deliverydate, d.deliverydate, 0, @userId
--from #tmpDraws d
from support_scDraws_Pub14_01172013 d


select dh.*
--from #tmpDraws tmp
from support_scDraws_Pub14_01172013 tmp
join scDrawHistory dh
	on tmp.DrawId = dh.DrawId
where changeddate = @changeddate

--drop table #tmpDraws

commit tran
