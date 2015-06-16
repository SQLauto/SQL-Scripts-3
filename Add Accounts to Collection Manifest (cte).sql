

begin tran

declare @acctcode nvarchar(25)
declare @manifestType nvarchar(80)
declare @beginDate datetime

set @acctcode = '0209225S'
set @manifestType = 'Collection'
set @beginDate = '11/26/2011'



;with cteExistingManifests
as (
	select m.ManifestId, m.ManifestTemplateId, ap.AccountPubID
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
			( @beginDate is null and m.ManifestId > 0 )
			or 
			( @beginDate is not null and m.ManifestDate >= @beginDate  )
		)
		
	--order by PubShortName, ManifestTypeDescription, Frequency
), cteExistingTemplates
as (
	select ap.AccountPubId, mst.ManifestSequenceTemplateId, mst.ManifestTemplateId, Sequence
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
)
insert into scmanifestsequences (manifestid, manifestsequencetemplateid, accountpubid, sequence)
select m.ManifestID, m.ManifestSequenceTemplateId, m.AccountPubID, m.Sequence
from (
	select m.ManifestID, m.ManifestDate, m.ManifestTemplateId, mt.ManifestSequenceTemplateId, mt.AccountPubID, mt.Sequence
	from scManifests m 
	join cteExistingTemplates mt	
		on m.ManifestTemplateId = mt.ManifestTemplateId
	where m.ManifestDate >= @beginDate
	) as m	
left join cteExistingManifests exm
	on m.ManifestID = exm.ManifestID
where exm.ManifestID is null
print cast(@@rowcount as varchar) + ' sequence records added'

commit tran