set nocount on

declare @msg varchar(512)
declare @rowcount int

--|  Manifests that have an UploadFinished timestamp, but are in the Uploading status
create table #uploading (
	[ManifestTransferId] [int] NOT NULL,
	[ManifestID] [int] NOT NULL,
	[MfstDate] [datetime] NOT NULL,
	[DeviceId] [int] NOT NULL,
	[MfstDownloadStarted] [datetime] NULL,
	[MfstDownloadFinished] [datetime] NULL,
	[MfstUploadStarted] [datetime] NULL,
	[MfstUploadFinished] [datetime] NULL,
	[MfstTransferStatus] [int] NOT NULL,
)

insert into #uploading (
	  ManifestTransferId
	, ManifestID
	, MfstDate
	, DeviceId
	, MfstDownloadStarted
	, MfstDownloadFinished
	, MfstUploadStarted
	, MfstUploadFinished
	, MfstTransferStatus
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
from scManifesttransfers tx
left join dd_scProcessingStates dd
	on tx.MfstTransferStatus = dd.ProcessingStateId
where MfstDownloadStarted is not null
and MfstDownloadFinished is not null
and MfstUploadStarted is not null
and MfstUploadFinished is not null
--and datediff(d, Mfstdate, getdate()) = 0
and dd.ProcessingStateId in ( select ProcessingStateId from dd_scProcessingStates where PSName in ( 'Uploading', 'Critical Error' ) )
order by 1 desc

update scManifestTransfers
set MfstTransferStatus = ( select ProcessingStateId from dd_scProcessingStates where PSName = 'Uploaded' )
from scManifestTransfers tx
join #uploading up
	on tx.ManifestTransferId = up.ManifestTransferId
set @rowcount = @@rowcount

if @rowcount > 0
begin
	select @msg = 'Set the status of ' + cast(@rowcount as varchar) + ' MfstTransfers to ''Uploaded''.'
	exec nsSystemLog_Insert 2, 0, @msg
end

insert into syncSystemLog (companyid, sltimestamp, logmessage, severityid, moduleid)
select 1, getdate(), 'Updated TransferStatus for Manifest ''' + m.MfstCode + ''' on ''' + convert(varchar, up.MfstDate, 1) + ''' from ''' + dd.PSName + ''' to ''Uploaded''.'
	, 1 as [Severity], 2 as [Module]
from #uploading up
join scManifests m
	on up.Manifestid = m.ManifestId
join dd_scProcessingStates dd
	on up.MfstTransferStatus = dd.ProcessingStateId

drop table #uploading

select sltimestamp, logmessage, sl.severityid, dd.severitydisplayname
from syncsystemlog sl
join dd_syncseverities dd
	on sl.severityid = dd.severityid
where sl.severityid >= 0
and datediff(d, sltimestamp, getdate()) = 0
order by sltimestamp desc
