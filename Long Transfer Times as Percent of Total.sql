begin tran

declare @deviceCode varchar(100)
declare @startDate datetime
declare @endDate datetime

set @deviceCode = null
set @startDate = '5/17/2009'
set @endDate = null

declare @uploadCount int
declare @longUploadCount int

--|Get Benchmarks
--|  Total # of Uploads
select @uploadCount = count(*)
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

select @uploadCount as [Total # of Uploads]

--|  How many of those uploads took an excessive amount of time?

--|  What is excessive?
--|	Avg Transfer Time = Drop Count * 3 seconds
select mt.ManifestId, mt.ManifestTransferId, count(*) as [Drops], cast(count(*) * 3 as decimal) / 60 as [AvgTime]
into #avgTransferTimes
from scManifestTransfers mt
join scManifestTransferDrops mtd
on mt.ManifestTransferId = mtd.ManifestTransferId 
group by mt.ManifestId, mt.ManifestTransferId

select @longUploadCount = count(*)
from scmanifesttransfers tx
join scmanifests m
	on tx.manifestid = m.manifestid
	and tx.mfstdate = m.manifestdate
join nsdevices d
	on m.deviceid = d.deviceid
join #avgTransferTimes tmp
	on tx.ManifestTransferId = tmp.ManifestTransferId
where 
	( @deviceCode is null and tx.manifesttransferid > 0
	  or d.DeviceCode = @deviceCode )
and 
	tx.MfstDate between isnull(@startDate, convert(varchar, getdate(), 1)) and isnull(@endDate, convert(varchar, getdate(), 1))
and
	tx.MfstUploadStarted is not null
and
	tx.MfstUploadFinished is not null
and 
	( cast( datediff(second, mfstUPloadstarted, mfstUPloadfinished) as decimal) / 60 ) - AvgTime > 1

select @longUploadCount as [# of Transfers with Excessive Upload Times]

select ( cast(@longUploadCount as decimal) / cast(@uploadCount as decimal) ) * 100as [%]

select    convert(varchar, tx.MfstDate, 1) as [Date]
	, m.MfstCode
	, tx.manifesttransferid, mfstUPloadstarted, mfstUPloadfinished
	, tmp.Drops
--	, datediff(second, mfstUPloadstarted, mfstUPloadfinished) as [time (in seconds)]
	, cast( datediff(second, mfstUPloadstarted, mfstUPloadfinished) as decimal) / 60 [time (in minutes)]
	, AvgTime
from scmanifesttransfers tx
join scmanifests m
	on tx.manifestid = m.manifestid
	and tx.mfstdate = m.manifestdate
join nsdevices d
	on m.deviceid = d.deviceid
join #avgTransferTimes tmp
	on tx.ManifestTransferId = tmp.ManifestTransferId
where 
	( @deviceCode is null and tx.manifesttransferid > 0
	  or d.DeviceCode = @deviceCode )
and 
	tx.MfstDate between isnull(@startDate, convert(varchar, getdate(), 1)) and isnull(@endDate, convert(varchar, getdate(), 1))
and
	tx.MfstUploadStarted is not null
and
	tx.MfstUploadFinished is not null
and 
	( cast( datediff(second, mfstUPloadstarted, mfstUPloadfinished) as decimal) / 60 ) - AvgTime > 1
order by 
	tx.MfstDate
	, cast( datediff(second, mfstUPloadstarted, mfstUPloadfinished) as decimal) / 60 desc

/*
select sltimestamp, logmessage
from syncsystemlog
where sltimestamp between dateadd(minute, -10, '2009-05-10 03:07:26.507') and dateadd(minute, 10, '2009-05-10 03:19:53.850')
order by sltimestamp 
*/

rollback tran