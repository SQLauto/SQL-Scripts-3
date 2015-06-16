begin tran

	select distinct tmp.AccountCode, tmp.ManifestCode, mt.MTCode
	from support_ReturnsManifest_Import tmp
	join scAccounts a
		on tmp.AccountCode = a.AcctCode
	join scAccountsPubs ap
		on a.AccountID = ap.AccountId
	join scManifestSequenceItems msi
		on ap.AccountPubID = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId	
	join scManifestTemplates mt
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	where ManifestTypeId = 4
	order by tmp.AccountCode

	delete msi
	from support_ReturnsManifest_Import tmp
	join scAccounts a
		on tmp.AccountCode = a.AcctCode
	join scAccountsPubs ap
		on a.AccountID = ap.AccountId
	join scManifestSequenceItems msi
		on ap.AccountPubID = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId	
	join scManifestTemplates mt
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	where ManifestTypeId = 4
	and tmp.ManifestCode <> mt.MTCode


	select distinct tmp.AccountCode, tmp.ManifestCode, mt.MTCode
	from support_ReturnsManifest_Import tmp
	join scAccounts a
		on tmp.AccountCode = a.AcctCode
	join scAccountsPubs ap
		on a.AccountID = ap.AccountId
	join scManifestSequenceItems msi
		on ap.AccountPubID = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId	
	join scManifestTemplates mt
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	where ManifestTypeId = 4
	order by tmp.AccountCode
		
commit tran	