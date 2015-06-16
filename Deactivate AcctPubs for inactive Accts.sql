

begin tran

select ap.AccountPubId
into #accountPubs
from scAccounts a
join scAccountsPubs ap
	on a.AccountId = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationId
where a.AcctActive = 0
and ap.Active = 1

--| Preview
select a.AccountId, a.AcctCode, p.PubShortName, a.AcctActive, ap.Active as [AcctPubActive]
from scAccounts a
join scAccountsPubs ap
	on a.AccountId = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationId
join #accountPubs tmp
	on tmp.AccountPubId = ap.AccountPubId

update scAccountsPubs
set Active = 0
from scAccounts a
join scAccountsPubs ap
	on a.AccountId = ap.AccountId
where a.AcctActive = 0
and ap.Active = 1
select 'Deactivated ' + cast(isnull(@@rowcount,0) as varchar) + ' records in scAccountsPubs.'

--|Review
select a.AccountId, a.AcctCode, p.PubShortName, a.AcctActive, ap.Active as [AcctPubActive]
from scAccounts a
join scAccountsPubs ap
	on a.AccountId = ap.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationId
join #accountPubs tmp
	on tmp.AccountPubId = ap.AccountPubId

drop table #accountPubs

commit tran