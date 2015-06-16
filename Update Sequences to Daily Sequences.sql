

begin tran

select MTCode, Code, Description, Frequency
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
order by MTCode
	
update scManifestSequenceTemplates 
set Code = rtrim(MTCode) + '_Seq'
	, Description = REPLACE(Description, 'Monday', 'Daily')
	, Frequency = 127
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
	
select MTCode, Code, Description, Frequency
from scManifestTemplates mt
join scManifestSequenceTemplates mst
	on mt.ManifestTemplateId = mst.ManifestTemplateId
order by MTCode

commit tran