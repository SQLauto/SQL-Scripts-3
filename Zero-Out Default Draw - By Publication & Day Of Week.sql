begin tran

select a.AccountId, ap.PublicationId 
	, AcctCode
	, PubShortName
	, drawweekday
	, case DrawWeekDay
		when 1 then 'Sun'
		when 2 then 'Mon'
		when 3 then 'Tue'
		when 4 then 'Wed'
		when 5 then 'Thu'
		when 6 then 'Fri'
		when 7 then 'Sat'
		end as [day]
	, dd.DrawAmount as [DefaultDraw]
into support_Backup_scDefaultDraws_01242012
from scAccounts a
join scaccountspubs ap
	on a.accountid = ap.accountid
join nspublications p
	on ap.publicationid = p.publicationid
join scdefaultdraws dd
	on ap.accountid = dd.accountid
	and ap.publicationid = dd.publicationid
where 
	pubshortname = 'ajcbd'
	and DrawWeekday <> 1
order by acctcode, drawweekday

select *
from support_Backup_scDefaultDraws_01242012

update scdefaultdraws
set DrawAmount = 0
from scAccounts a
join scaccountspubs ap
	on a.accountid = ap.accountid
join nspublications p
	on ap.publicationid = p.publicationid
join scdefaultdraws dd
	on ap.accountid = dd.accountid
	and ap.publicationid = dd.publicationid
where 
	pubshortname = 'ajcbd'
	and DrawWeekday <> 1

select tmp.*, dd.DrawAmount as [newDrawAmount]
from scdefaultdraws dd
join support_Backup_scDefaultDraws_01242012 tmp
	on dd.accountid = tmp.accountid
	and dd.publicationid = tmp.publicationid
	and dd.drawweekday = tmp.drawweekday

commit tran