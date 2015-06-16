
declare @mfstCode nvarchar(25)

set @mfstCode = 'mfst1'

select mt.ManifestTemplateId, mt.MTCode, typ.ManifestTypeDescription as [ManfiestType], d.DeviceCode
from scManifestTemplates mt
join nsDevices d
	on mt.DeviceId = d.DeviceId
join dd_scManifestTypes typ
	on mt.ManifestTypeId = typ.ManifestTypeId
where mt.MTCode = @mfstCode

