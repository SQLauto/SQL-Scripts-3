select 
	a.AcctCode--, a.AccountId,
	, PubShortName
	, mt.MTCode--, mt.ManifestTemplateId
	, typ.ManifestTypeDescription as [Type]
	, mst.Code--, mst.ManifestSequenceTemplateId
	, mst.Frequency
	, ap.AccountPubID
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
join scAccountsPubs ap
	on msi.AccountPubId = ap.AccountPubId
join scAccounts a
	on ap.AccountId = a.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationId
join dd_scManifestTypes typ
	on 	mt.ManifestTypeId = typ.ManifestTypeId
where a.AcctCode = '10051361'
--mt.MTCode = 'mfst1'
order by PubShortName, typ.ManifestTypeDescription, mst.Frequency

