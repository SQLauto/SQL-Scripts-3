begin tran
/*
	This script will reset the status of a given manifest transfer (or set of manifest transfers)
	based on the download/upload timestamps.
*/
declare @deviceCode nvarchar(20)
declare @mfstDate datetime
declare @finalProcessingStateId int
declare @finalProcessingState nvarchar(20)

set @deviceCode = null
set @mfstDate = null--'4/20/2011'

set @finalProcessingState = null  --| leave this null unless you wish to specify the final processing state

--|  Use a temp table so we can check the status after the update
select ManifestTransferId, dev.DeviceCode, PSName, tx.MfstDate
	, MfstDownloadStarted, MfstDownloadFinished
	, MfstUploadStarted, MfstUploadFinished
	, case 
		when 
			( MfstDownloadStarted is null ) 
			and ( MfstDownloadFinished is null )
			and ( MfstUploadStarted is null )
			and ( MfstUploadFinished is null ) 	then 7 --'Cancelled'
		when 
			( MfstDownloadStarted is not null )
			and ( MfstDownloadFinished is null ) 
			and ( MfstUploadStarted is null )
			and ( MfstUploadFinished is null ) 	then 10 --'Downloading'	
		when 
			( MfstDownloadStarted is not null ) 
			and ( MfstDownloadFinished is not null )
			and ( MfstUploadStarted is null )
			and ( MfstUploadFinished is null ) 	then 11 --'Downloaded'
		when 
			( MfstDownloadStarted is NOT null )
			and ( MfstDownloadFinished is NOT null ) 
			and ( MfstUploadStarted is NOT null )
			and ( MfstUploadFinished is null )	then 12 --'Uploading'
		when 
			( MfstDownloadStarted is NOT null )
			and ( MfstDownloadFinished is NOT null ) 
			and ( MfstUploadStarted is NOT null )
			and ( MfstUploadFinished is NOT null )	then 13 --'Uploaded'	
		else @finalProcessingStateId
		end as [NewStatusId]	
	, case
		when 
			( MfstDownloadStarted is null ) 
			and ( MfstDownloadFinished is null )
			and ( MfstUploadStarted is null )
			and ( MfstUploadFinished is null ) 	then 'Cancelled' 
		when 
			( MfstDownloadStarted is not null )
			and ( MfstDownloadFinished is null ) 
			and ( MfstUploadStarted is null )
			and ( MfstUploadFinished is null ) 	then 'Downloading'	
		when 
			( MfstDownloadStarted is not null ) 
			and ( MfstDownloadFinished is not null )
			and ( MfstUploadStarted is null )
			and ( MfstUploadFinished is null ) 	then 'Downloaded'
		when 
			( MfstDownloadStarted is NOT null )
			and ( MfstDownloadFinished is NOT null ) 
			and ( MfstUploadStarted is NOT null )
			and ( MfstUploadFinished is null )	then 'Uploading'
		when 
			( MfstDownloadStarted is NOT null )
			and ( MfstDownloadFinished is NOT null ) 
			and ( MfstUploadStarted is NOT null )
			and ( MfstUploadFinished is NOT null )	then 'Uploaded'	
		else @finalProcessingState
		end as [NewStatus]
into #mfstTransfers
from scManifestTransfers tx
join dd_scProcessingStates dd
	on tx.mfstTransferstatus = dd.ProcessingStateId
join nsDevices dev
	on tx.DeviceId = dev.DeviceId
where mfstTransferstatus = ( select ProcessingStateId from dd_scProcessingStates where PSName = 'Critical Error' )
and ( 
		(
		@deviceCode is not null 
		and DeviceCode = @deviceCode )
	or ( 
		@deviceCode is null 
		and dev.DeviceId > 0 )
	)
and ( 
		(
		@mfstDate is not null 
		and MfstDate = @mfstDate )
	or ( 
		@mfstDate is null 
		and tx.ManifestTransferId > 0 )
	)

--|  Get the ProcessingStateId
select @finalProcessingStateId = ( 
		select ProcessingStateId
		from dd_scProcessingStates
		where PSName = @finalProcessingState
		)

update scManifestTransfers
set MfstTransferstatus =  case 
				when isnull( @finalProcessingStateId, 0 ) = 0 then tmp.NewStatusId  
				else 7
			end
from scManifestTransfers mt
join #mfstTransfers tmp
	on mt.ManifestTransferId = tmp.ManifestTransferId

select
	  dev.DeviceCode, mt.MfstDate
	, tmp.PSName as [Old Processing State]
	, dd.PSName as [New Processing State]
	, mt.MfstDownloadStarted, mt.MfstDownloadFinished
	, mt.MfstUploadStarted, mt.MfstUploadFinished
from scManifestTransfers mt
join #mfstTransfers tmp
	on mt.ManifestTransferId = tmp.ManifestTransferId
join dd_scProcessingStates dd
	on mt.mfstTransferstatus = dd.ProcessingStateId
join nsDevices dev
	on mt.DeviceId = dev.DeviceId

drop table #mfstTransfers

rollback tran