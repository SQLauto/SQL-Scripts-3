



select MTCode, mt.ManifestTemplateId, prelim.count
from (
	select ManifestSequenceTemplateId, COUNT(*) as [count]
	from scManifestSequenceItems
	group by ManifestSequenceTemplateId
	) prelim
join scManifestSequenceTemplates mst
	on prelim.ManifestSequenceTemplateId = mst.ManifestSequenceTemplateId
join scManifestTemplates mt
	on mst.ManifestTemplateId = mt.ManifestTemplateId
order by prelim.count desc