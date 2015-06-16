
--|revert
--|  These are the manifest sequence items that were added
select *
from scManifestSequenceItems msi
left join tmpBackup_scManifestSequenceItems_11102010 tmp
	on msi.ManifestSequenceItemId = tmp.ManifestSequenceItemId
where tmp.ManifestSequenceItemId is null