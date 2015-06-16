begin tran

;with cte
as (
	select 'Adams Trk 010' as [old], 'Metro Trk 010' as [new]
	union all select 'Adams Trk 105', 'Metro Trk 105'
	union all select 'Adams Trk 115', 'Metro Trk 115'
	union all select 'Adams Trk 120', 'Metro Trk 120'
	union all select 'Adams Trk 200', 'Metro Trk 200'
	union all select 'Adams Trk 220', 'Metro Trk 220'
	union all select 'Adams Trk 300', 'Metro Trk 300'
	union all select 'Adams Trk 310', 'Metro Trk 310'
	union all select 'Adams Trk 600', 'Metro Trk 600'
	union all select 'Adams Trk 630', 'Metro Trk 630'
)
select mt.ManifestTemplateId, [old], [new]
into support_ManifestNameUpdate
from cte 
join scManifestTemplates mt
	on cte.old = mt.MTName
	
update scManifestTemplates 
set MTName = [new]
from support_ManifestNameUpdate tmp
join scManifestTemplates mt
	on tmp.ManifestTemplateId = mt.ManifestTemplateId


--select m.ManifestID, m.MfstCode, m.MfstName, cte.new
update scmanifests
	set MfstName = [new]
from support_ManifestNameUpdate tmp
join scManifests m
	on tmp.ManifestTemplateId = m.ManifestTemplateId
	
select distinct tmp.*, mt.MTName, m.MfstName
from support_ManifestNameUpdate tmp
join scManifestTemplates mt
	on tmp.ManifestTemplateId = mt.ManifestTemplateId
join scmanifests m
	on mt.ManifestTemplateId = m.ManifestTemplateId


commit tran	