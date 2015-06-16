declare @acctcode nvarchar(25)
declare @manifestType nvarchar(80)

set @acctcode = '0048518'
set @manifestType = null

select a.AcctCode, PubShortName, mt.MTCode, mst.Code, mst.Frequency,typ.ManifestTypeDescription
	--, msi.Sequence
	, mt.ManifestTemplateId, mst.ManifestSequenceTemplateId, a.AccountId, ap.AccountPubID
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
	on mt.ManifestTypeId = typ.ManifestTypeId	
where (
		( @acctcode is null and a.AccountID > 0 )
		or 
		( @acctcode is not null and a.AcctCode = @acctcode )
	)
and ( 
		( @manifestType is null and mt.ManifestTemplateId > 0 )
		or 
		( @manifestType is not null and typ.ManifestTypeDescription = @manifestType )
	)

	
order by PubShortName, Frequency