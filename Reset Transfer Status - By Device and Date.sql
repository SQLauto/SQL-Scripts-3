
begin tran

declare @DeviceCode nvarchar(20)
declare @mfstDate datetime

set @DeviceCode = 'W05B'
set @mfstDate = '12/22/2010'

	select DeviceCode, PSName, tx.*
	from scManifestTransfers tx
	join dd_scProcessingStates dd
		on tx.mfstTransferstatus = dd.ProcessingStateId
	join nsDevices dev
		on tx.DeviceId = dev.DeviceId
	where ( DeviceCode = @DeviceCode 
		or ( 
			@DeviceCode is null 
			and dev.DeviceId > 0 )
		)
	and ( MfstDate = @mfstDate
		or ( 
			@mfstDate is null 
			and tx.ManifestTransferId > 0 )
		)
	--and mfstTransferstatus = ( select ProcessingStateId from dd_scProcessingStates where PSName = 'Critical Error' )

update scManifestTransfers
set MfstTransferstatus =  ( select ProcessingStateId from dd_scProcessingStates where PSName = 'Downloaded' )
where ManifestTransferId in 
	(	
		select ManifestTransferId
		from scManifestTransfers tx
		join dd_scProcessingStates dd
			on tx.mfstTransferstatus = dd.ProcessingStateId
		join nsDevices dev
			on tx.DeviceId = dev.DeviceId
		where ( DeviceCode = @DeviceCode 
		or ( 
			@DeviceCode is null 
			and dev.DeviceId > 0 )
		)
		and ( MfstDate = @mfstDate
			or ( 
				@mfstDate is null 
				and tx.ManifestTransferId > 0 )
			)
		--and mfstTransferstatus = ( select ProcessingStateId from dd_scProcessingStates where PSName = 'Critical Error' )
	)
	
	select DeviceCode, PSName, tx.*
	from scManifestTransfers tx
	join dd_scProcessingStates dd
		on tx.mfstTransferstatus = dd.ProcessingStateId
	join nsDevices dev
		on tx.DeviceId = dev.DeviceId
	where ( DeviceCode = @DeviceCode 
		or ( 
			@DeviceCode is null 
			and dev.DeviceId > 0 )
		)
	and ( MfstDate = @mfstDate
		or ( 
			@mfstDate is null 
			and tx.ManifestTransferId > 0 )
		)
	--and mfstTransferstatus = ( select ProcessingStateId from dd_scProcessingStates where PSName = 'Critical Error' )
		
commit tran