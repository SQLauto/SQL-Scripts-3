

;with cte1
as (
	select a.AcctCode, p.PubShortName, a.AccountId, ap.AccountPubId, ap.PublicationId, d.DrawAmount
	from scManifests m
	join scManifestSequences ms
		on m.ManifestId = ms.ManifestId
	join scAccountsPubs ap
		on ms.accountPubId = ap.AccountPubId
	join scAccounts a
		on ap.AccountId = a.AccountId
	join nsPublications p
		on ap.PublicationId = p.PublicationId	
	join scDraws d
		on ap.AccountId = d.AccountId
		and ap.PublicationId = d.PublicationId
		and m.ManifestDate = d.DrawDate
	where m.MfstCode = 'SC1501'
	and m.ManifestDate = '09/02/2011'
),
cte2
as (
	select a.AcctCode, p.PubShortName, a.AccountId, ap.AccountPubId, ap.PublicationId, d.DrawAmount
	from scManifests m
	join scManifestSequences ms
		on m.ManifestId = ms.ManifestId
	join scAccountsPubs ap
		on ms.accountPubId = ap.AccountPubId
	join scAccounts a
		on ap.AccountId = a.AccountId
	join nsPublications p
		on ap.PublicationId = p.PublicationId	
	join scDraws d
		on ap.AccountId = d.AccountId
		and ap.PublicationId = d.PublicationId
		and m.ManifestDate = d.DrawDate
	where m.MfstCode = 'SC1501'
	and m.ManifestDate = '08/31/2011'
)
select *
from cte1
full outer join cte2
	on cte1.AcctCode = cte2.AcctCode
	and cte1.PubShortName = cte2.PubShortName
where cte1.AccountPubId is null	
or cte2.AccountPubId is null