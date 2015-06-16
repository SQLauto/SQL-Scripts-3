

begin tran

declare @manifestDate datetime
declare @mfstcode nvarchar(25)

set @manifestDate = '8/6/2012'
set @mfstcode = null

;with cteManifestTemplates
as (
	select m.MfstCode, m.ManifestDate
		--, dbo.scGetDayFrequency(m.ManifestDate), mst.Frequency
		, m.ManifestID, m.ManifestTemplateId, mst.ManifestSequenceTemplateId
		, msi.AccountPubId, msi.Sequence
	from scManifests m
	join scManifestTemplates mt
		on m.ManifestTemplateId = mt.ManifestTemplateId
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
		and mst.Frequency &  dbo.scGetDayFrequency(m.ManifestDate) > 0
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId	
	where datediff(d, m.ManifestDate, @manifestDate) = 0
	and (
		( @mfstcode is null and m.ManifestID > 0 )
		or
		( @mfstcode is not null and m.MfstCode = @mfstcode )
	)
	--order by MfstCode, Sequence
),
cteManifests 
as (
	select m.ManifestID, ManifestTemplateId, ManifestSequenceTemplateId, AccountPubId, Sequence
	from scManifests m
	join scManifestSequences ms
		on m.ManifestID = ms.ManifestId
	where datediff(d, m.ManifestDate, @manifestDate) = 0
	and (
		( @mfstcode is null and m.ManifestID > 0 )
		or
		( @mfstcode is not null and m.MfstCode = @mfstcode )
	)
)
select mt.ManifestId, mt.ManifestSequenceTemplateId, mt.AccountPubId, mt.Sequence
into support_scManifestSequences_ItemsAdded_08092012_Temp_2
from cteManifestTemplates mt
left join cteManifests m
	on mt.ManifestID = m.ManifestID
	and mt.ManifestTemplateId = m.ManifestTemplateId
	and mt.ManifestSequenceTemplateId = m.ManifestSequenceTemplateId
	and mt.AccountPubId = m.AccountPubId
where m.ManifestID is null

insert into scManifestSequences ( ManifestId, ManifestSequenceTemplateId, AccountPubId, Sequence )
select *
from support_scManifestSequences_ItemsAdded_08092012_Temp_2


commit tran