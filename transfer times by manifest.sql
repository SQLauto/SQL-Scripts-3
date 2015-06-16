begin tran

declare @deviceCode varchar(100)
declare @startDate datetime
declare @endDate datetime

set @deviceCode = null
set @startDate = '5/16/2009'
set @endDate = null

select m.MfstCode
	, manifesttransferid, mfstUPloadstarted, mfstUPloadfinished
	, datediff(second, mfstUPloadstarted, mfstUPloadfinished) as [time (in seconds)]
	, cast( datediff(second, mfstUPloadstarted, mfstUPloadfinished) as decimal) / 60 [time (in minutes)]
from scmanifesttransfers tx
join scmanifests m
	on tx.manifestid = m.manifestid
	and tx.mfstdate = m.manifestdate
join nsdevices d
	on m.deviceid = d.deviceid
where ( @deviceCode is null and tx.manifesttransferid > 0
	or d.DeviceCode = @deviceCode )
and 
	tx.MfstDate between isnull(@startDate, convert(varchar, getdate(), 1)) and isnull(@endDate, convert(varchar, getdate(), 1))
and
	tx.MfstUploadStarted is not null
and
	tx.MfstUploadFinished is not null
order by 
	[time (in minutes)] desc

select sltimestamp, logmessage
from syncsystemlog
where sltimestamp between dateadd(minute, -10, '2009-05-10 03:07:26.507') and dateadd(minute, 10, '2009-05-10 03:19:53.850')
order by sltimestamp 
