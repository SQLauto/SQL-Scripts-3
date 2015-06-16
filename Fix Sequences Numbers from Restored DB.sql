
begin tran

--|for comparison after the update
select mt.MTCode, mst.Code, msi.ManifestSequenceItemId, msi.ManifestSequenceTemplateId, msi.AccountPubid, msi.Sequence, tmp.Sequence as [Recovered Seq]
into #sequences
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
join NSDB30_RECOVERED..scManifestSequenceItems tmp
	on msi.ManifestSequenceItemId = tmp.ManifestSequenceItemId
	and msi.ManifestSequenceTemplateId = tmp.ManifestSequenceTemplateId
	and msi.AccountPubId = tmp.AccountPubId
where msi.Sequence <> tmp.Sequence

select *
from #sequences

update scManifestSequenceItems
set Sequence = tmp.Sequence
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
join NSDB30_RECOVERED..scManifestSequenceItems tmp
	on msi.ManifestSequenceItemId = tmp.ManifestSequenceItemId
	and msi.ManifestSequenceTemplateId = tmp.ManifestSequenceTemplateId
	and msi.AccountPubId = tmp.AccountPubId
where msi.Sequence <> tmp.Sequence

select mt.MTCode, mst.Code, msi.ManifestSequenceItemId, msi.ManifestSequenceTemplateId, msi.AccountPubid, msi.Sequence, tmp.[Recovered Seq]
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
join #sequences tmp
	on msi.ManifestSequenceItemId = tmp.ManifestSequenceItemId
	and msi.ManifestSequenceTemplateId = tmp.ManifestSequenceTemplateId
	and msi.AccountPubId = tmp.AccountPubId

drop table #sequences

rollback tran