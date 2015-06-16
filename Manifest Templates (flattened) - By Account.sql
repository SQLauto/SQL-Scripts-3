select
		a.AcctCode, MTCode, MTName
		, mst.Code
		, typ.ManifestTypeDescription as [Type]
		, PubShortName 
		, mst.Frequency
		, dbo.support_DayNames_FromFrequency(mst.Frequency) as [FrequencyList]
		, case when mst.Frequency & 1 > 0 then ' X ' else ' - ' end as [sun]
		, case when mst.Frequency & 2 > 0 then ' X ' else ' - ' end as [mon]
		, case when mst.Frequency & 4 > 0 then ' X ' else ' - ' end as [tue]
		, case when mst.Frequency & 8 > 0 then ' X ' else ' - ' end as [wed]
		, case when mst.Frequency & 16 > 0 then ' X ' else ' - ' end as [thu]
		, case when mst.Frequency & 32 > 0 then ' X ' else ' - ' end as [fri]
		, case when mst.Frequency & 64 > 0 then ' X ' else ' - ' end as [sat]
		, ap.AccountPubID 
		, mst.ManifestSequenceTemplateId
		, ManifestSequenceItemId

	from nsPublications p
	join scAccountsPubs ap
		on p.PublicationID = ap.PublicationId
	join scManifestSequenceItems msi
		on ap.AccountPubID = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId	
	join scManifestTemplates mt
		on mst.ManifestTemplateId = mt.ManifestTemplateId
	join scAccounts a
		on ap.AccountId = a.AccountID	
	join dd_scManifestTypes typ
		on mt.ManifestTypeId = typ.ManifestTypeId	
	where MTName = 'SCIC_3603_D03'
	order by AcctCode
	
	
	select
		a.AcctCode, MTCode, MTName
		, mst.Code
		, typ.ManifestTypeDescription as [Type]
		, PubShortName 
		, mst.Frequency
		, dbo.support_DayNames_FromFrequency(mst.Frequency) as [FrequencyList]
		, case when mst.Frequency & 1 > 0 then ' X ' else ' - ' end as [sun]
		, case when mst.Frequency & 2 > 0 then ' X ' else ' - ' end as [mon]
		, case when mst.Frequency & 4 > 0 then ' X ' else ' - ' end as [tue]
		, case when mst.Frequency & 8 > 0 then ' X ' else ' - ' end as [wed]
		, case when mst.Frequency & 16 > 0 then ' X ' else ' - ' end as [thu]
		, case when mst.Frequency & 32 > 0 then ' X ' else ' - ' end as [fri]
		, case when mst.Frequency & 64 > 0 then ' X ' else ' - ' end as [sat]
		, ap.AccountPubID 
		, mst.ManifestSequenceTemplateId
		, ManifestSequenceItemId

	from nsPublications p
	join scAccountsPubs ap
		on p.PublicationID = ap.PublicationId
	join scManifestSequenceItems msi
		on ap.AccountPubID = msi.AccountPubId
	join scManifestSequenceTemplates mst
		on msi.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId	
	join scManifestTemplates mt
		on mst.ManifestTemplateId = mt.ManifestTemplateId
	join scAccounts a
		on ap.AccountId = a.AccountID	
	join dd_scManifestTypes typ
		on mt.ManifestTypeId = typ.ManifestTypeId	
	where AcctCode = '00010450'
	and mst.Frequency & 64 > 0
	order by AcctCode
	
	
	