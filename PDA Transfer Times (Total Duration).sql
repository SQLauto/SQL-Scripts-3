

declare @devicecode nvarchar(50)
declare @date datetime

set @devicecode = null
set @date = '6/18/2013'--getdate()

--|downloads
;with cteDownloads as (
	select mfstdate, mfstcode, devicecode
		, mfstdownloadstarted, mfstdownloadfinished
		, datediff( second, mfstdownloadstarted, mfstdownloadfinished ) as [download elapsed]
		, mfstuploadstarted, mfstuploadfinished
		, datediff( second, mfstuploadstarted, mfstuploadfinished ) as [upload elapsed]

	from scmanifesttransfers mt
	join nsdevices dev
		on mt.deviceid = dev.deviceid
	join scmanifests m
		on m.manifestid = mt.manifestid
	where  
		( 
			( (@devicecode is not null) and (dev.devicecode = @devicecode) )
		or ( @devicecode is null and manifesttransferid > 0 )
		)
	and (
		( datediff( d, mfstdate, @date ) = 0 )
		or ( @date is null and manifesttransferid > 0 )
		)
)
, cteUploads
as (
	select mfstdate, mfstcode, devicecode
		, mfstdownloadstarted, mfstdownloadfinished
		, datediff( second, mfstdownloadstarted, mfstdownloadfinished ) as [download elapsed]
		, mfstuploadstarted, mfstuploadfinished
		, datediff( second, mfstuploadstarted, mfstuploadfinished ) as [upload elapsed]

	from scmanifesttransfers mt
	join nsdevices dev
		on mt.deviceid = dev.deviceid
	join scmanifests m
		on m.manifestid = mt.manifestid
	where  
		( 
			( (@devicecode is not null) and (dev.devicecode = @devicecode) )
		or ( @devicecode is null and manifesttransferid > 0 )
		)
	and (
		( datediff( d, MfstUploadStarted, dateadd(d, 0, @date)) = 0 )
		or ( @date is null and manifesttransferid > 0 )
		)
)
select d.MfstCode, d.DeviceCode
	, dbo.support_Duration( u.MfstUploadStarted, d.MfstDownloadFinished) as [Total Duration]
	, u.MfstUploadStarted, u.MfstUploadFinished, u.[upload elapsed]
	, d.MfstDownloadStarted, d.MfstDownloadFinished, d.[download elapsed]
from cteDownloads d
join cteUploads u
	on d.MfstCode = u.MfstCode
	and d.DeviceCode = u.DeviceCode