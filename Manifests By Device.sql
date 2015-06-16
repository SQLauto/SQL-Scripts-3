
declare @deviceCode nvarchar(25)

set @deviceCode = '001'

select m.ManifestId, m.MfstCode, m.ManifestDate, typ.ManifestTypeName, d.DeviceCode
from scManifests m
join nsDevices d
	on m.DeviceId = d.DeviceId
join dd_scManifestTypes typ
	on m.ManifestTypeId = typ.ManifestTypeId
where datediff(d, ManifestDate, getdate()) = 0
and d.DeviceCode = @deviceCode

update scmanifests
set DeviceId = null
where ManifestId in ( 5613, 5616)

