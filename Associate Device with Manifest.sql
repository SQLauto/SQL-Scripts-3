begin tran

declare @devCode nvarchar(10)
declare @mfstCode nvarchar(25)
declare @date datetime

set @devCode = '010'
set @mfstCode = 'Mfst10'
set @date = convert(varchar, getdate(), 1)

select m.ManifestId, convert(varchar, ManifestDate, 1) as [ManifestDate], MfstCode, DeviceCode
from scManifests m
left join nsDevices d
	on m.DeviceId = d.DeviceId
where datediff(d, ManifestDate, @date) = 0
and MfstCode = @mfstCode

update scManifests
set DeviceId = ( select DeviceId from nsDevices where DeviceCode = @devCode )
where datediff(d, ManifestDate, @date) = 0
and MfstCode = @mfstCode


select m.ManifestId, convert(varchar, ManifestDate, 1) as [ManifestDate], MfstCode, DeviceCode
from scManifests m
join nsDevices d
	on m.DeviceId = d.DeviceId
where datediff(d, ManifestDate, @date) = 0
and MfstCode = @mfstCode

commit tran