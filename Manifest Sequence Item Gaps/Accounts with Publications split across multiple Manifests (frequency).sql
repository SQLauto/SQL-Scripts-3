/*
	Accounts with Publications split across multiple Manifests
*/

declare @acctcode nvarchar(20)
set @acctcode = null
		
select tmp1.*, tmp2.*
from (	
	select a.AcctCode, mt.ManifestTemplateId, MTCode, typ.ManifestTypeDescription, mst.Frequency
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
	where (
			( @acctcode is null and a.AccountID > 0 )
			or ( a.AcctCode = @acctcode )
			)
	group by a.AcctCode, mt.ManifestTemplateId, MTCode, typ.ManifestTypeDescription, mst.Frequency	
	) as [tmp1]
join (
	select a.AcctCode, mt.ManifestTemplateId, MTCode, typ.ManifestTypeDescription, mst.Frequency
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
	where (
			( @acctcode is null and a.AccountID > 0 )
			or ( a.AcctCode = @acctcode )
			)
	group by a.AcctCode, mt.ManifestTemplateId ,MTCode, typ.ManifestTypeDescription, mst.Frequency	
	) as [tmp2]
	on tmp1.AcctCode = tmp2.AcctCode
	and tmp1.ManifestTypeDescription = tmp2.ManifestTypeDescription
where tmp1.Frequency & tmp2.Frequency > 0
and tmp1.MTCode <> tmp2.MTCode
and tmp1.ManifestTemplateId > tmp2.ManifestTemplateId
order by tmp1.AcctCode