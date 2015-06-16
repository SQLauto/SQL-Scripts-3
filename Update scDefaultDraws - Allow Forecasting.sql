begin tran

select *
into scDefaultDraws_BACKUP_05112009_FULL
from scDefaultDraws

select dd.*
into scDefaultDraws_BACKUP_05112009
from book1 b
right join scaccounts a
	on b.routeid = a.acctcode
join nspublications p
	on b.productid = p.pubshortname
right join scdefaultdraws dd
	on a.accountid = dd.accountid
	and datepart(dw, b.drawdate) = dd.drawweekday
	and p.publicationid = dd.publicationid
join scaccountspubs ap
	on dd.accountid = ap.accountid
	and dd.publicationid = ap.publicationid
join scaccounts a2
	on a2.accountid = ap.accountid
where b.drawtotal is null
and ( dd.drawamount > 0
	or dd.allowforecasting > 0 )
and a2.acctactive > 0
and ap.active > 0 
order by dd.accountid

update scdefaultdraws
set DrawAmount = 0
	, AllowForecasting = 0
from book1 b
right join scaccounts a
	on b.routeid = a.acctcode
join nspublications p
	on b.productid = p.pubshortname
right join scdefaultdraws dd
	on a.accountid = dd.accountid
	and datepart(dw, b.drawdate) = dd.drawweekday
	and p.publicationid = dd.publicationid
join scaccountspubs ap
	on dd.accountid = ap.accountid
	and dd.publicationid = ap.publicationid
join scaccounts a2
	on a2.accountid = ap.accountid
where b.drawtotal is null
and ( dd.drawamount > 0
	or dd.allowforecasting > 0 )
and a2.acctactive > 0
and ap.active > 0 

select dd.drawamount as [new drawamount], dd2.drawamount as [old drawamount], dd.allowforecasting as [new allow forecasting], dd2.allowforecasting as [old allow forecasting]
from scdefaultdraws dd
join scdefaultdraws_backup_05112009 dd2
	on dd.accountid = dd2.accountid
	and dd.publicationid = dd2.publicationid
	and dd.drawweekday = dd2.drawweekday

COMMIT TRAN