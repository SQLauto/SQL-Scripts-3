

select MTCode, sum(mst.frequency), dbo.frequency_to_dayList( sum(mst.frequency) )
from scManifestTemplates mt
join scManifestSequenceTemplates mst
on mt.ManifestTemplateId = mst.ManifestTemplateId
where mt.ManifestTypeId = 1
and MTDeleted <> 1
group by MTCode



