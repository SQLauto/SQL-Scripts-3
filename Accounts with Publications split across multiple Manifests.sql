
/*
	This query will list Accounts that have publication split across multiple manifests
*/
	select AcctCode, ManifestTypeDescription, COUNT(*)
	from (	
		select a.AcctCode, MTCode, typ.ManifestTypeDescription
		from scAccounts a
		join scAccountsPubs ap
			on a.AccountID = ap.AccountId
		join scManifestSequenceItems msi
			on ap.AccountPubID = msi.AccountPubId
		join scManifestSequenceTemplates mst
			on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
		join scManifestTemplates mt
			on mst.ManifestTemplateId = mt.ManifestTemplateId
		join dd_scManifestTypes typ
			on mt.ManifestTypeId = typ.ManifestTypeId
		group by a.AcctCode, MTCode, typ.ManifestTypeDescription	
	) as [tmp]
	group by AcctCode, ManifestTypeDescription
	having COUNT(*) > 1	
	order by AcctCode
