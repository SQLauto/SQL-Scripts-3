

begin tran

	declare @beginDate datetime
	declare @endDate datetime

	set @beginDate = convert(nvarchar, getdate(), 101)
	set @endDate = convert(nvarchar, getdate(), 101)

	select m.ManifestDate, m.MfstCode ,m.DeviceId as [DeviceId (manifest)], mt.DeviceId as [DeviceId (template)]
	from scManifests m
	join scManifestTemplates mt
		on m.ManifestTemplateId = mt.ManifestTemplateId
	where m.ManifestDate between @beginDate and @endDate
	and isnull(m.DeviceId,-1) <> isnull(mt.DeviceId,-1) 

	update scManifests
	set deviceid = mt.DeviceId
	from scManifests m
	join scManifestTemplates mt
		on m.ManifestTemplateId = mt.ManifestTemplateId
	where m.ManifestDate between @beginDate and @endDate
	and isnull(m.DeviceId,-1) <> isnull(mt.DeviceId,-1)

	select m.ManifestDate, m.MfstCode ,m.DeviceId as [DeviceId (manifest)], mt.DeviceId as [DeviceId (template)]
	from scManifests m
	join scManifestTemplates mt
		on m.ManifestTemplateId = mt.ManifestTemplateId
	where m.ManifestDate between @beginDate and @endDate
	and isnull(m.DeviceId,-1) <> isnull(mt.DeviceId,-1) 

commit tran