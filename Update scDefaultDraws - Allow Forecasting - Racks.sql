begin tran

select dd.*
into scDefaultDraws_BACKUP_04032012
from scDefaultDraws dd
join scAccounts a
	on dd.AccountID = a.AccountID	
join dd_scAccountTypes typ
	on a.AccountTypeID = typ.AccountTypeID	
where typ.ATName = 'rack'

update scdefaultdraws
set AllowForecasting = 0
from scDefaultDraws dd
join scAccounts a
	on dd.AccountID = a.AccountID	
join dd_scAccountTypes typ
	on a.AccountTypeID = typ.AccountTypeID	
where typ.ATName = 'rack'

select dd.allowforecasting as [new allow forecasting], dd2.allowforecasting as [old allow forecasting]
from scdefaultdraws dd
join scdefaultdraws_backup_04032012 dd2
	on dd.AccountID = dd2.accountid
	and dd.PublicationID = dd2.publicationid
	and dd.DrawWeekday = dd2.DrawWeekday
join scAccounts a
	on dd.AccountID = a.AccountID	
join dd_scAccountTypes typ
	on a.AccountTypeID = typ.AccountTypeID	
where typ.ATName = 'rack'

commit TRAN