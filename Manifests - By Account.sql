declare @acctcode nvarchar(25)
declare @manifestType nvarchar(80)
declare @manifestDate datetime

set @acctcode = 'ac109'
set @manifestType = null
set @manifestDate = '3/4/2011'

select m.ManifestDate, a.AcctCode, PubShortName, m.MfstCode, typ.ManifestTypeDescription
	--, msi.Sequence
	--, m.ManifestId, mst.ManifestSequenceTemplateId, a.AccountId, ap.AccountPubID
from scManifests m
join scManifestSequences ms
	on m.ManifestId = ms.ManifestId
join scAccountsPubs ap
	on ms.AccountPubId = ap.AccountPubId
join scAccounts a
	on ap.AccountId = a.AccountId
join nsPublications p
	on ap.PublicationId = p.PublicationId
join dd_scManifestTypes typ
	on m.ManifestTypeId = typ.ManifestTypeId	
where (
		( @acctcode is null and a.AccountID > 0 )
		or 
		( @acctcode is not null and a.AcctCode = @acctcode )
	)
and ( 
		( @manifestType is null and m.ManifestId > 0 )
		or 
		( @manifestType is not null and typ.ManifestTypeDescription = @manifestType )
	)
and ( 
		( @manifestDate is null and m.ManifestId > 0 )
		or 
		( @manifestDate is not null and m.ManifestDate = @manifestDate )
	)
	
--order by PubShortName, ManifestTypeDescription, Frequency