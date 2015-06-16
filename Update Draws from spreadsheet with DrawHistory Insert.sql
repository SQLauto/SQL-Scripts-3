

begin tran

declare @changeddate datetime
declare @changetype int
declare @userId int


set @changeddate = GETDATE()

select @userId = UserId
from Users
where UserName = 'support@syncronex.com'
if @@rowcount = 0
	set @userId = 1

--print @userId

select @changetype = ChangeTypeID
from dd_nsChangeTypes
where ChangeTypeDescription = 'User Edit'

/*
select d.DrawID, TMP.[Draw Qty], d.DrawAmount as [olddraw]
into support_TDAY_AJC_BACKUP
from support_TDAY tmp
join scAccounts a
	on tmp.Account = a.AcctCode
join nsPublications p
	on tmp.Pub = p.PubShortName	
left join scDraws d
	on a.AccountID = d.AccountID
	and p.PublicationID = d.PublicationID
	and tmp.[Pub Date] = d.DrawDate
--where d.DrawID is null
*/

update scDraws
set DrawAmount = tmp.[Draw Qty]
	, LastChangeType = @changetype
from support_TDAY_AJC_BACKUP tmp
join scDraws d
	on tmp.DrawID = d.DrawID

/*
insert into scDrawHistory ( companyid, distributioncenterid, accountid, publicationid, drawid, drawweekday
	, changeddate, drawdate, olddraw, newdraw, oldrate, newrate, olddeliverydate, newdeliverydate, changetypeid, userid )

select distinct d.companyid, d.distributioncenterid, d.accountid, d.publicationid, d.drawid, d.drawweekday
	, @changeddate, d.drawdate, tmp.olddraw, tmp.[Draw Qty] [newdraw], d.drawrate, d.drawrate 
	, d.deliverydate, d.deliverydate, @changetype, @userId
from support_TDAY_AJC_BACKUP tmp
join scDraws d
	on tmp.DrawID = d.DrawID
*/

select dh.*
from support_TDAY_AJC_BACKUP tmp
join scDrawHistory dh
	on tmp.DrawId = dh.DrawId
--where changeddate = @changeddate

--drop table #tmpDraws

commit tran
