
select a.AcctCode, p.PubShortName, a.AcctActive, ap.Active as [AcctPubActive]
from scAccountsPubs ap
join scAccounts a
	on ap.AccountId = a.AccountID
join nsPublications p
	on ap.PublicationId = p.PublicationID
left join (
	select ap.AccountPubId
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId	
	join scAccountsPubs ap
		on msi.AccountPubId = ap.AccountPubID
	) as assigned
	on ap.AccountPubID = assigned.AccountPubID
where assigned.AccountPubID	is null
order by AcctCode