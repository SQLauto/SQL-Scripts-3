

declare @devicecode nvarchar(50)
declare @date datetime

set @devicecode = null
set @date = getdate()


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
where ( 
	( dev.devicecode = @devicecode )
	or ( @devicecode is null and manifesttransferid > 0 )
	)
and (
	( datediff( d, mfstdate, @date ) = 0 )
	or ( @date is null and manifesttransferid > 0 )
	)
and mfstuploadfinished is not null
order by mfstdate desc, mfstcode, devicecode