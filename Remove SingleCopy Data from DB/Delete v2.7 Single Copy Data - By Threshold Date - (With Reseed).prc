IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'syncDataCleanup_DeleteDateRange' 
	   AND 	  type = 'P')
    DROP PROCEDURE dbo.syncDataCleanup_DeleteDateRange
GO

CREATE PROCEDURE dbo.syncDataCleanup_DeleteDateRange
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

	set @src = 'syncDataCleanup_DeleteDateRange'
	set @msg = @src + ': Procedure beginning with parameters: thresholdDate=' + convert(nvarchar, @thresholdDate, 1)
	print @msg
	exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

  ---------------------------
--|	Database Statistics		|--
  ---------------------------
	CREATE TABLE #helpdb (
		[name] nvarchar(100)
		,[dbsize] nvarchar(25)
		,[owner] nvarchar(25)
		,[dbid] int
		,[created] datetime
		,[status] nvarchar(256)
		,[compatiblity_level] int
	   )

	INSERT INTO #helpdb
	EXEC sp_helpdb

	select @dbname = [name]
			,@dbsize = [dbsize]
	from #helpdb
	where [name] = ( select db_name() )
	
	set @msg = @src + ': database size is ' + @dbsize
	print @msg
	exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src
	
    set @msg = @src + ': Data older than ' + convert(nvarchar, @thresholdDate, 1) + ' will be Deleted.'
	print @msg
	exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|Create temp table of data to delete
	select DrawId
	into #delete
	from scdraws
	where drawdate < @thresholdDate

	--|  scDrawAdjustmentsAudit
		delete from scDrawAdjustmentsAudit
		where DrawId in (
			select DrawId
			from #delete
			)


		set @msg = @src + ': Deleted ' + cast(@@rowcount as nvarchar) + ' rows from [scDrawAdjustmentsAudit]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src
		
	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )

	--|  scDrawAdjustments
		delete from scDrawAdjustments 
		where DrawId in (
			select DrawId
			from #delete
			)

		set @msg = @src + ': Deleted ' + cast(@@rowcount as nvarchar) + ' rows from [scDrawAdjustments]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )

	--|  scReturns & scReturnsAudit
		delete from scReturnsAudit
		where DrawId in (
			select DrawId
			from #delete
			)

		set @msg = @src + ': Deleted ' + cast(@@rowcount as nvarchar) + ' rows from [scReturnsAudit]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

		delete from scReturns
		where DrawId in(
			select DrawId
			from #delete
			)

		set @msg = @src + ': Deleted ' + cast(@@rowcount as nvarchar) + ' rows from [scReturns]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )

	--|  scDraws
		delete from scDraws
		where DrawId in (
			select DrawId
			from #delete
			)

		set @msg = @src + ': Deleted ' + cast(@@rowcount as nvarchar) + ' rows from [scDraws]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )

	--|  scTemporaryDraws
		delete from scTemporaryDraws
		where effectivedateend < @thresholdDate

		set @msg = @src + ': Deleted ' + cast(@@rowcount as nvarchar) + ' rows from [scTemporaryDraws]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src


	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )
	
	--|  scDefaultDrawHistory
		delete from scDefaultDrawHistory
		where drawhistorydate < @thresholdDate

		set @msg = @src + ': Deleted ' + cast(@@rowcount as nvarchar) + ' rows from [scDefaultDrawHistory]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )

	--| scDrawForecasts
		delete from scDrawForecasts
		where dfdate < @thresholdDate

		set @msg = @src + ': Deleted ' + cast(@@rowcount as nvarchar) + ' rows from [scDrawForecasts]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )

	--|  scManifestUploadData
		delete from scManifestUploadData
		where exists ( 
			select *
			from scmanifesthistory his
			where scmanifestuploaddata.manifestid = his.manifestid
			and scmanifestuploaddata.manifesthistoryid = his.manifesthistoryid
			and mheffectivedate < @thresholdDate
			)

		set @msg = @src + ': Deleted ' + cast(@@rowcount as nvarchar) + ' rows from [scManifestUploadData]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  scManifestHistory
		delete from scManifestHistory
		where mheffectivedate < @thresholdDate

		set @msg = @src + ': Deleted ' + cast(@@rowcount as nvarchar) + ' rows from [scManifestHistory]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )

	--|  syncSystemLog
		delete from syncSystemLog
		where SLTimestamp < @thresholdDate

	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )

	--| scManifestDownloadCancellations
	if exists (select name from sysobjects where name = N'scManifestDownloadCancellations' and type = 'U' )
	begin
		delete from scManifestDownloadCancellations
		where exists (
			select *
			from scmanifesttransfers trx
			where scmanifestdownloadcancellations.manifesttransferid = trx.manifesttransferid
			and mfstdate < @thresholdDate
			)

		set @msg = @src + ': Deleted ' + cast(@@rowcount as nvarchar) + ' rows from [scManifestDownloadCancellations]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src
	end

	--| scManifestDownladTrx
	if exists (select name from sysobjects where name = N'scManifestDownloadTrx' and type = 'U' )
	begin
		delete from scManifestDownloadTrx
		where manifestdate < @thresholdDate

		set @msg = @src + ': Deleted ' + cast(@@rowcount as nvarchar) + ' rows from [scManifestDownloadTrx]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src
	end

  	--| scManifestTransferDrops
  	if exists (select name from sysobjects where name = N'scManifestTransferDrops' and type = 'U' )
	begin
		delete from scManifestTransferDrops
		where exists (
			select *
			from scmanifesttransfers xfer
			where scmanifesttransferdrops.manifesttransferid = xfer.manifesttransferid
			and xfer.mfstdate < @thresholdDate
		)

		set @msg = @src + ': Deleted ' + cast(@@rowcount as nvarchar) + ' rows from [scManifestTransferDrops]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src
	end

	--| scManifestTransfers
	if exists (select name from sysobjects where name = N'scManifestTransfers' and type = 'U' )
	begin
		delete from scManifestTransfers
		where mfstdate < @thresholdDate

		set @msg = @src + ': Deleted ' + cast(@@rowcount as nvarchar) + ' rows from [scManifestTransfers]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src
	end

	truncate table #helpdb
	insert into #helpdb
	exec sp_helpdb

	select @dbname = [name]
			,@dbsize = [dbsize]
	from #helpdb
	where [name] = ( select db_name() )
	
	set @msg = @src + ': database size is ' + @dbsize
	print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	drop table #helpdb

	set @msg = @src + ': Procedure Completed'
	print @msg
	exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src
GO