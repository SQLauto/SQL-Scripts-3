
begin tran

delete scManifestHistory
from scManifestHistory mh
join scmanifests m
	on m.ManifestID = mh.ManifestID
join scManifestTemplates mt
	on m.ManifestTemplateId = mt.ManifestTemplateId
where MTDeleted = 1

delete scManifestSequences
from scManifests m
join scManifestSequences ms
	on m.ManifestID = ms.ManifestId
join scManifestTemplates mt
	on m.ManifestTemplateId = mt.ManifestTemplateId
where MTDeleted = 1

delete scManifests 
from scManifests m
join scManifestTemplates mt
	on m.ManifestTemplateId = mt.ManifestTemplateId
where MTDeleted = 1

delete scManifestSequenceTemplates
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
where MTDeleted = 1

delete 
from scManifestTemplates
where MTDeleted = 1

select *
from scManifestTemplates

commit tran