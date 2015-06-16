
declare @msg varchar(512)

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[scManifestTransfers_DEBUG]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[scManifestTransfers_DEBUG](
	[ManifestTransferId] [int] NOT NULL,
	[ManifestID] [int] NOT NULL,
	[MfstDate] [datetime] NOT NULL,
	[DeviceId] [int] NOT NULL,
	[MfstDownloadStarted] [datetime] NULL,
	[MfstDownloadFinished] [datetime] NULL,
	[MfstUploadStarted] [datetime] NULL,
	[MfstUploadFinished] [datetime] NULL,
	[MfstTransferStatus] [int] NOT NULL,
	[LastChanged] [timestamp] NOT NULL
) ON [PRIMARY]
END

--|  Manifests who have a DownloadFinished timestamp, but are still in the Downloading status
insert into scManifestTransfers_DEBUG (
	  ManifestTransferId
	, ManifestID
	, MfstDate
	, DeviceId
	, MfstDownloadStarted
	, MfstDownloadFinished
	, MfstUploadStarted
	, MfstUploadFinished
	, MfstTransferStatus
--, LastChanged
)
select tx.ManifestTransferId
	, tx.ManifestID
	, tx.MfstDate
	, tx.DeviceId
	, tx.MfstDownloadStarted
	, tx.MfstDownloadFinished
	, tx.MfstUploadStarted
	, tx.MfstUploadFinished
	, tx.MfstTransferStatus
	--, tx.LastChanged
from scManifesttransfers tx
left join dd_scProcessingStates dd
	on tx.MfstTransferStatus = dd.ProcessingStateId
where MfstDownloadStarted is not null
and MfstDownloadFinished is not null
and MfstUploadStarted is null
and MfstUploadFinished is null
and datediff(d, Mfstdate, getdate()) = 0
and dd.ProcessingStateId = ( select ProcessingStateId from dd_scProcessingStates where PSName = 'Downloading' )
order by 1 desc

--select *
--from scManifestTransfers_DEBUG
--where datediff(d, mfstdate, getdate()) = 0

--select @msg = 'Found ' + cast(isnull(@@rowcount,0) as varchar) + ' transfers with status of ''Downloading'' that have a value for MfstDownloadFinished.'
--exec nsSystemLog_Insert 2, 0, @msg

--|Acknowledged Manifests
select convert(varchar, sltimestamp, 1) as [Date]
	, ltrim( rtrim( substring(
		logmessage
		, charindex('Acknowledged receipt of Manifest ', logmessage, 0) + len('Acknowledged receipt of Manifest ')
		, charindex(' (', logmessage, 0) - ( charindex('Acknowledged receipt of Manifest ', logmessage, 0) + len('Acknowledged receipt of Manifest ') )
	) ) )  as [ManifestId]
	, ltrim( rtrim( substring(
		logmessage
		, charindex('(', logmessage, 0) + len('(')
		, charindex(')', logmessage, 0) - (charindex('(', logmessage, 0) + len('('))
	) ) )  as [MfstCode]
into #Acknowledged
from syncsystemlog
where logmessage like 'Device % Acknowledged receipt of Manifest % (%)'
and datediff(d, sltimestamp, getdate()) = 0

--debug
--select *
--from #Acknowledged

update scManifestTransfers
set MfstTransferStatus = ( select ProcessingStateId from dd_scProcessingStates where PSName = 'Downloaded' )
from scManifestTransfers tx
join scManifestTransfers_DEBUG dbg
	on tx.ManifestTransferId = dbg.ManifestTransferId
join #Acknowledged ack
	on dbg.MfstDate = ack.Date
	and dbg.ManifestId = ack.ManifestId
where datediff(d, dbg.MfstDate, getdate()) = 0

select @msg = 'Set the status of ' + cast(isnull(@@rowcount,0) as varchar) + ' MfstTransfers to ''Downloaded''.'
exec nsSystemLog_Insert 2, 0, @msg

drop table #Acknowledged