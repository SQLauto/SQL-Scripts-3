IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'syncDataCleanup_DeleteDateRange_Manifests' 
	   AND 	  type = 'P')
    DROP PROCEDURE dbo.syncDataCleanup_DeleteDateRange_Manifests
GO

CREATE PROCEDURE dbo.syncDataCleanup_DeleteDateRange_Manifests
	@thresholdDate datetime  --| Data older than the threshold date will be deleted
AS
	set nocount on

	declare @sql nvarchar(2048)

	declare @msg    nvarchar(1024)
	declare @src	nvarchar(50)

	declare @name nvarchar(100)
	select @name = db_name()

	declare @dbname nvarchar(256)
	declare @dbsize nvarchar(25)

	declare @rowcount int
	set @rowcount = 0

	set @src = 'syncDataCleanup_DeleteDateRange_Manifests'
	set @msg = @src + ': Procedure beginning with parameters: thresholdDate=' + convert(nvarchar, @thresholdDate, 1)
	print @msg
	--exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	
    set @msg = @src + ': Data older than ' + convert(nvarchar, @thresholdDate, 1) + ' will be Deleted.'
	print @msg
	--exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src


--|Manifests

	select ManifestID
	into #manifestsToDelete
	from scManifests
	where ManifestDate < @thresholdDate

	print 'deleting data from table [scManifestDownloadCancellations]'
	delete mdc
	from [scManifestDownloadCancellations] mdc
	join scManifestTransfers mt
		on mdc.ManifestTransferId = mt.ManifestTransferId
	join #manifestsToDelete tmp
		on mt.ManifestID = tmp.ManifestID
	--set @rowcount = @@rowcount
	print '  ' + cast(@rowcount as varchar) + ' rows deleted from [scManifestDownloadCancellations]'
	print ''
	--|  Shrink
		if @rowcount > 0
		begin 
			print 'shrinking database...'
			dbcc shrinkdatabase( @name, truncateonly ) WITH NO_INFOMSGS
		end
		
	print 'deleting data from table [scManifestTransferDrops]'
	delete mtd
	from [scManifestTransferDrops] mtd
	join scManifestTransfers mt
		on mtd.ManifestTransferId = mt.ManifestTransferId
	join #manifestsToDelete tmp
		on mt.ManifestID = tmp.ManifestID
	--set @rowcount = @@rowcount
	print '  ' + cast(@rowcount as varchar) + ' rows deleted from [scManifestTransferDrops]'
	print ''
	--|  Shrink
		if @rowcount > 0
		begin 
			print 'shrinking database...'
			dbcc shrinkdatabase( @name, truncateonly ) WITH NO_INFOMSGS
		end

	print 'deleting data from table [scManifestTransfers]'
	delete mt
	from [scManifestTransfers] mt
	join #manifestsToDelete tmp
		on mt.ManifestID = tmp.ManifestID
	--set @rowcount = @@rowcount
	print '  ' + cast(@rowcount as varchar) + ' rows deleted from [scManifestTransfers]'
	print ''
	--|  Shrink
		if @rowcount > 0
		begin 
			print 'shrinking database...'
			dbcc shrinkdatabase( @name, truncateonly ) WITH NO_INFOMSGS
		end

	print 'deleting data from table [scManifestHistory]'
	delete mh
	from [scManifestHistory] mh
	join #manifestsToDelete tmp
		on mh.ManifestID = tmp.ManifestID
	--set @rowcount = @@rowcount
	print '  ' + cast(@rowcount as varchar) + ' rows deleted from [scManifestHistory]'
	print ''
	--|  Shrink
		if @rowcount > 0
		begin 
			print 'shrinking database...'
			dbcc shrinkdatabase( @name, truncateonly ) WITH NO_INFOMSGS
		end

	print 'deleting data from table [scManifestSequences]'
	delete ms
	from [scManifestSequences] ms
	join #manifestsToDelete tmp
		on ms.ManifestId = tmp.ManifestID
	--set @rowcount = @@rowcount
	print '  ' + cast(@rowcount as varchar) + ' rows deleted from [scManifestSequences]'
	print ''
	--|  Shrink
		if @rowcount > 0
		begin 
			print 'shrinking database...'
			dbcc shrinkdatabase( @name, truncateonly ) WITH NO_INFOMSGS
		end

	print 'deleting data from table [scManifests]'
	delete m
	from [scManifests] m
	join #manifestsToDelete tmp
		on m.ManifestID = tmp.ManifestID
	set @rowcount = @@rowcount
	print '  ' + cast(@rowcount as varchar) + ' rows deleted from [scManifests]'
	print ''

	--|  Shrink
		if @rowcount > 0
		begin 
			print 'shrinking database...'
			dbcc shrinkdatabase( @name, truncateonly ) WITH NO_INFOMSGS
		end

	set @msg = @src + ': Procedure Completed'
	print @msg
	--exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	drop table #manifestsToDelete
GO