begin tran

if not exists ( 
	select *
	from sysobjects
	where id = object_id('pk_scDraws')
	)
begin
	alter table dbo.scDraws
	add 	CONSTRAINT [PK_scDraws] PRIMARY KEY  NONCLUSTERED 
	(
		[CompanyID],
		[DistributionCenterID],
		[AccountID],
		[PublicationID],
		[DrawWeekday],
		[DrawID]
	)  ON [PRIMARY] 
	print ' added costraint [pk_scDraws] to table [scDraws]'
end

if not exists ( 
	select *
	from sysobjects
	where id = object_id('PK_scReturnsAudit')
	)
begin
	alter table scReturnsaudit
	add CONSTRAINT [PK_scReturnsAudit] PRIMARY KEY  CLUSTERED 
	(
		[CompanyId],
		[DistributionCenterId],
		[AccountId],
		[PublicationId],
		[DrawWeekday],
		[DrawId],
		[ReturnId],
		[ReturnsAuditId]
	)  ON [PRIMARY] 
		print ' added costraint [PK_scReturnsAudit] to table [scReturnsaudit]'
end

if not exists ( 
	select *
	from sysobjects
	where id = object_id('PK_scDrawAdjustmentsAudit')
	)
begin
	alter table scDrawAdjustmentsaudit
	add CONSTRAINT [PK_scDrawAdjustmentsAudit] PRIMARY KEY  CLUSTERED 
	(
		[CompanyId],
		[DistributionCenterId],
		[AccountId],
		[PublicationId],
		[DrawWeekday],
		[DrawId],
		[DrawAdjustmentId],
		[DrawAdjustmentAuditId]
	)  ON [PRIMARY] 
		print ' added costraint [PK_scDrawAdjustmentsAudit] to table [scDrawAdjustmentsaudit]'
end

if not exists ( 
	select *
	from sysobjects
	where id = object_id('PK_scManifestHistory')
	)
begin
	alter table scManifestHistory
	add CONSTRAINT [PK_scManifestHistory] PRIMARY KEY  NONCLUSTERED 
	(
		[CompanyID],
		[DistributionCenterID],
		[ManifestID],
		[ManifestHistoryID]
	)  ON [PRIMARY] 
	print ' added costraint [PK_scManifestHistory] to table [scManifestHistory]'
end

if not exists ( 
	select *
	from sysforeignkeys
	where constid = object_id('FK_scManifestHistory_scManifests')
	)
begin
	alter table scManifestHistory
	add CONSTRAINT [FK_scManifestHistory_scManifests] FOREIGN KEY 
	(
		[CompanyID],
		[DistributionCenterID],
		[ManifestID]
	) REFERENCES [dbo].[scManifests] (
		[CompanyID],
		[DistributionCenterID],
		[ManifestID]
	) 
	
	print ' added costraint [FK_scManifestHistory_scManifests] to table [scManifestHistory]'
end

if not exists ( 
	select *
	from sysforeignkeys
	where constid = object_id('FK_scManifestUploadData_scManifestHistory')
	)
begin
	alter table scManifestUploadData
	add CONSTRAINT [FK_scManifestUploadData_scManifestHistory] FOREIGN KEY 
	(
		[CompanyId],
		[DistributionCenterId],
		[ManifestId],
		[ManifestHistoryId]
	) REFERENCES [dbo].[scManifestHistory] (
		[CompanyID],
		[DistributionCenterID],
		[ManifestID],
		[ManifestHistoryID]
	) 
	
	print ' added costraint [FK_scManifestUploadData_scManifestHistory] to table [scManifestUploadData]'
end


if not exists ( 
	select *
	from sysforeignkeys
	where constid = object_id('fk_mfstdowntrx_manifests')
	)
begin
	alter table [dbo].[scManifestDownloadTrx]
	add 	CONSTRAINT fk_mfstdowntrx_manifests FOREIGN KEY
	(
		companyid,
		distributioncenterid,
		manifestid
	) 
	REFERENCES dbo.scManifests
	(
		companyid,
		distributioncenterid,
		manifestid
	) 
	
	print ' added costraint [fk_mfstdowntrx_manifests] to table [scManifestDownloadTrx]'
end


if not exists ( 
	select *
	from sysindexes
	where name = 'ix_manifestKeyInfo'
	)
begin
	create unique index [ix_manifestKeyInfo] on [dbo].[scManifestTransfers] ( ManifestId,MfstDate )	
	print ' added costraint [ix_manifestKeyInfo] to table [scManifestTransfers]'
end



commit tran