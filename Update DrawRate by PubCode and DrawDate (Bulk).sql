begin tran
/*
update Rate to 3.95 for 4/4 for pub YSEEE 
*/


;with cteAccounts
as (
select '20053802' as [AcctCode]
union all select '20053433'
union all select '21600053'
union all select '20064048'
union all select '21600056'
union all select '20070705'
union all select '21600057'
union all select '21309010'
union all select '21607025'
union all select '21309027'
union all select '21607033'
union all select '40006297'
union all select '40000001'
union all select '40022371'
union all select '40000313'
union all select '20055804'
union all select '40001642'
union all select '20055814'
union all select '40003197'
union all select '20055842'
union all select '40006937'
union all select '40019960'
union all select '40023008'
)
select d.DrawID, a.AcctCode, p.PubShortName, d.DrawDate, d.DrawRate
into supportBackup_scDraws_adhoc_rate_update_04142011
from cteAccounts cte
join scAccounts a 
	on cte.AcctCode = a.AcctCode
join scAccountsPubs ap
	on a.AccountID = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationID
join scDraws d
	on ap.AccountId = d.AccountID
	and ap.PublicationId = d.PublicationID
where p.PubShortName = 'YSEEE'
and d.DrawDate = '4/4/2011'

update scDraws
set DrawRate = 3.95
from scDraws d
join supportBackup_scDraws_adhoc_rate_update_04142011 tmp
	on d.DrawID = tmp.DrawId

select tmp.*, d.DrawRate as [new rate]
from scDraws d
join supportBackup_scDraws_adhoc_rate_update_04142011 tmp
	on d.DrawID = tmp.DrawId

commit tran