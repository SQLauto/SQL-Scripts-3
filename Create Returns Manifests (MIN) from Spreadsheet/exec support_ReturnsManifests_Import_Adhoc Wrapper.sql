begin tran

select MTCode, mst.Code, mst.Frequency, COUNT(msi.ManifestSequenceItemId)
from scManifestTemplates mt
left join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
left join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId	
where MTCode in ( '203-ret', '202-ret')
group by MTCode, mst.Code, mst.Frequency

exec [support_ReturnsManifests_Import_Adhoc]

select MTCode, mst.Code, mst.Frequency, COUNT(msi.ManifestSequenceItemId)
from scManifestTemplates mt
left join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
left join scManifestSequenceItems msi
	on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId	
where MTCode in ( '203-ret', '202-ret')
group by MTCode, mst.Code, mst.Frequency

commit tran
