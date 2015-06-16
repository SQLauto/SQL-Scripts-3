
;with ctePU as (
	select msi.AccountPubId, mst.Frequency, mt.ManifestTypeId
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	where MTCode = 'scr-pu'
)
, cteAll as (
	select msi.AccountPubId, mst.Frequency, mt.ManifestTypeId
	from scManifestTemplates mt
	join scManifestSequenceTemplates mst
		on mt.ManifestTemplateId = mst.ManifestTemplateId
	join scManifestSequenceItems msi
		on mst.ManifestSequenceTemplateId = msi.ManifestSequenceTemplateId
	where MTCode <> 'scr-pu'	
)
select *
from ctePU
join cteAll
	on ctePU.AccountPubId = cteAll.AccountPubId
	and ctePU.ManifestTypeId = cteAll.ManifestTypeId
	
	