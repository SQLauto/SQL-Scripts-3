BEGIN TRAN

declare @DeviceCode nvarchar(20)
set @DeviceCode = 'W05B'

--|  Preview:  Transfers in Critical Error status, with no upload timestamps
select DeviceCode, PSName, tx.*
from scManifestTransfers tx
join dd_scProcessingStates dd
	on tx.mfstTransferstatus = dd.ProcessingStateId
join nsDevices dev
	on tx.DeviceId = dev.DeviceId
where mfstTransferstatus = ( select ProcessingStateId from dd_scProcessingStates where PSName = 'Critical Error' )
and ( 
		mfstdownloadstarted is not null
		and mfstdownloadfinished is not null
		and mfstuploadstarted is not null
		and mfstuploadfinished is not null
	)
and ( DeviceCode = @DeviceCode 
	or ( 
		@DeviceCode is null 
		and dev.DeviceId > 0 )
	)

--|  Use a temp table so we can check the status after the update
select ManifestTransferId
into #mfstTransfers
from scManifestTransfers tx
join dd_scProcessingStates dd
	on tx.mfstTransferstatus = dd.ProcessingStateId
join nsDevices dev
	on tx.DeviceId = dev.DeviceId
where mfstTransferstatus = ( select ProcessingStateId from dd_scProcessingStates where PSName = 'Critical Error' )
and ( 
		mfstdownloadstarted is not null
		and mfstdownloadfinished is not null
		and mfstuploadstarted is not null
		and mfstuploadfinished is not null
	)
and ( DeviceCode = @DeviceCode 
	or ( 
		@DeviceCode is null 
		and dev.DeviceId > 0 )
	)

update scManifestTransfers
set MfstTransferstatus =  ( select ProcessingStateId from dd_scProcessingStates where PSName = 'Uploaded' )
where ManifestTransferId in 
	(	
		select ManifestTransferId
		from #mfstTransfers
	)

select DeviceCode, PSName, tx.*
from scManifestTransfers tx
join dd_scProcessingStates dd
	on tx.mfstTransferstatus = dd.ProcessingStateId
join nsDevices dev
	on tx.DeviceId = dev.DeviceId
where ManifestTransferId in (
	select ManifestTransferId
	from #mfstTransfers
	)

drop table #mfstTransfers

commit tran