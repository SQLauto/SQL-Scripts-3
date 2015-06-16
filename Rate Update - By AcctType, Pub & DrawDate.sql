
begin tran

select d.DrawID, p.PubShortName, typ.ATName, d.DrawRate as [OldRate]
into support_NBOY_RateUpdate_2
from scDraws d
join nsPublications p
	on d.PublicationID = p.PublicationID
join scAccounts a
	on d.AccountID = a.AccountID
join dd_scAccountTypes typ
	on a.AccountTypeID = typ.AccountTypeID
where ATName in ('NBOY', 'HBOX')
and PubShortName in (
	'INAC', 'INC', 'INAB', 'INB'
	, 'DNDA', 'DNDF', 'SWSA', 'SWSF'
)
--and d.DrawDate in ('2/16/2015','2/17/2015')	
and d.DrawDate >= '2/16/2015'
--group by p.PubShortName, typ.ATName, d.DrawRate
order by p.PubShortName

update d
set DrawRate = 
	case 
		when ( typ.ATName = 'HBOX' AND PubShortName in ('INAC', 'INC', 'INAB', 'INB')) then .82000
		when ( typ.ATName = 'HBOX' AND PubShortName in ('DNDA', 'DNDF', 'SWSA', 'SWSF')) then .82000
		
		when ( typ.ATName = 'NBOY' AND PubShortName in ('INAC', 'INC', 'INAB', 'INB')) then .85000
		when ( typ.ATName = 'NBOY' AND PubShortName in ('DNDA', 'DNDF', 'SWSA', 'SWSF')) then .83000
		else d.DrawRate
		end
from scDraws d
join nsPublications p
	on d.PublicationID = p.PublicationID
join scAccounts a
	on d.AccountID = a.AccountID
join dd_scAccountTypes typ
	on a.AccountTypeID = typ.AccountTypeID
where ATName in ('NBOY', 'HBOX')
and PubShortName in (
	'NAC', 'INC', 'INAB', 'INB'
	, 'DNDA', 'DNDF'
	, 'SWSA', 'SWSF'
)
--and d.DrawDate in ('2/16/2015','2/17/2015')	
and d.DrawDate >= '2/16/2015'


select d.DrawID, a.AcctCode, p.PubShortName, typ.ATName, d.DrawDate, d.DrawRate, tmp.oldrate
into support_RateUpdate_Backup
from support_NBOY_RateUpdate_2 tmp
join scDraws d
	on tmp.drawid = d.DrawID
join nsPublications p
	on d.PublicationID = p.PublicationID
join scAccounts a
	on d.AccountID = a.AccountID
join dd_scAccountTypes typ
	on a.AccountTypeID = typ.AccountTypeID
where typ.ATName in ('NBOY', 'HBOX')
and p.PubShortName in (
	'INAC', 'INC', 'INAB', 'INB'
	, 'DNDA', 'DNDF', 'SWSA', 'SWSf'
)
--and d.DrawDate in ('2/16/2015','2/17/2015')	
and d.DrawDate >= '2/16/2015'
--group by p.PubShortName, typ.ATName, d.DrawRate
order by a.AcctCode, p.PubShortName, d.DrawDate

commit tran