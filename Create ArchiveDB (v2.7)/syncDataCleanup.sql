IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'syncDataCleanup_DateRange' 
	   AND 	  type = 'P')
    DROP PROCEDURE dbo.syncDataCleanup_DateRange
GO

CREATE PROCEDURE dbo.syncDataCleanup_DateRange
	@beginDate datetime
	,@endDate datetime
	,@archivedb nvarchar(256) = null
AS
	set nocount on
	declare @sql nvarchar(2048)

	declare @msg    nvarchar(1024)
	declare @src	nvarchar(50)
	declare @count	int

	declare @name nvarchar(100)
	select @name = db_name()

	declare @dbname nvarchar(256)
	declare @dbsize nvarchar(25)

	set @src = 'syncDataCleanup_DateRange'
	set @msg = @src + ': Procedure beginning with parameters: beginDate=' + convert(nvarchar, @beginDate, 1) + ', endDate=' + convert(nvarchar, @endDate, 1)  + ', archiveDB=' + @archiveDB
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
	
	--|Get the threshold date based on the number of month's worth of data to preserve

    -- make sure our dates reflect midnight of start to 11:59pm of end
    declare @chardate   varchar(10)
    set @chardate = convert(varchar(10),@beginDate,101)
    set @beginDate    = cast( @chardate as datetime )

    set @chardate = convert(varchar(10),@endDate,101)
    set @endDate     = cast( @chardate + ' 23:59:59' as datetime )

	set @msg = @src + ': Data between ' + convert(nvarchar, @beginDate, 1) + ' and ' + convert(nvarchar, @endDate, 1)  + ' will be Archived & Deleted.'
	print @msg
	exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|Create temp table of data to preserve
	select DrawId
	into #archive
	from scdraws
	where drawdate between @beginDate and @endDate

	--|  Archive:  scDraws
		set @sql = 'select * into ' + @archivedb + '..scDraws '
		set @sql = @sql + ' from scDraws where drawdate between ''' + convert(nvarchar, @beginDate, 1) + ''' and ''' + convert(nvarchar, @endDate, 1)  + ''''
		print @sql 
		exec (@sql)


	--|  Archive:  scDrawAdjustments & scDrawAdjustmentsAudit
		set @sql = 'select adj.* into ' + @archivedb + '..scDrawAdjustments '
		set @sql = @sql + ' from scDrawAdjustments adj join ' + @archivedb + '..scDraws arc on adj.DrawId = arc.DrawId'
		print @sql 
		exec (@sql)

		set @sql = 	  'select aud.* into ' + @archivedb + '..scDrawAdjustmentsAudit '
		set @sql = @sql + ' from scDrawAdjustmentsAudit aud join ' + @archivedb + '..scDrawAdjustments adj on adj.DrawId = aud.DrawId and adj.DrawAdjustmentId = aud.DrawAdjustmentId' 
		print @sql 
		exec (@sql)

	--|  Delete:  scDrawAdjustmentsAudit
		delete from scDrawAdjustmentsAudit
		where DrawId in (
			select DrawId
			from #archive
			)
		set @count = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scDrawAdjustmentsAudit]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

		
	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )

	--|  Delete:  scDrawAdjustments
		delete from dbo.scDrawAdjustments
		where DrawId in (
			select DrawId
			from #archive
			)
		set @count = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scDrawAdjustments]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )


	--|  Archive:  scReturns & scReturnsAudit
		set @sql = 'select ret.* into ' + @archivedb + '..scReturns  '
		set @sql = @sql + ' from scReturns ret join ' + @archivedb + '..scDraws arc on ret.DrawId = arc.DrawId'
		print @sql 
		exec (@sql)

		set @sql = 	  'select aud.* into ' + @archivedb + '..scReturnsAudit '
		set @sql = @sql + ' from scReturnsAudit aud join ' + @archivedb + '..scReturns ret on ret.DrawId = aud.DrawId and ret.ReturnId = aud.ReturnId' 
		print @sql 
		exec (@sql)

	--|  Delete:  scReturns & scReturnsAudit
		delete from scReturnsAudit
		where DrawId in (
			select DrawId
			from #archive
			)
		set @count = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scReturnsAudit]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

		delete from scReturns
		where DrawId in(
			select DrawId
			from #archive
			)
		set @count = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scReturns]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )


	--|  Delete:  scDraws
		delete from scDraws
		where DrawId in (
			select DrawId
			from #archive
			)
		set @count = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scDraws]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )

	--|  Archive:  scTemporaryDraws
		set @sql = 	  'select * into ' + @archivedb + '..scTemporaryDraws '
		set @sql = @sql + ' from scTemporaryDraws where effectivedateend between ''' + convert(nvarchar, @beginDate, 1) + ''' and ''' + convert(nvarchar, @endDate, 1)  + ''''
		print @sql 
		exec (@sql)

	--|  Delete:  scTemporaryDraws
		delete from scTemporaryDraws
		where effectivedateend between @beginDate and @endDate
		set @count = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scTemporaryDraws]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src


	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )

/*
	--|  Archive:  scDrawHistory
		set @sql = 	  'select * into ' + @archivedb + '..scDefaultDrawHistory '
		set @sql = @sql + ' from scDefaultDrawHistory where drawhistorydate between ''' + convert(nvarchar, @beginDate, 1) + ''' and ''' + convert(nvarchar, @endDate, 1)  + ''''
		print @sql 
		exec (@sql)
*/

	--|  Archive:  scDefaultDrawHistory
		set @sql = 	  'select * into ' + @archivedb + '..scDefaultDrawHistory '
		set @sql = @sql + ' from scDefaultDrawHistory where drawhistorydate between ''' + convert(nvarchar, @beginDate, 1) + ''' and ''' + convert(nvarchar, @endDate, 1)  + ''''
		print @sql 
		exec (@sql)
	
	--|  Delete:  scDefaultDrawHistory
		delete from scDefaultDrawHistory
		where drawhistorydate between @beginDate and @endDate
		set @count = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scDefaultDrawHistory]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )

	--|  Archive:  scDrawForecasts
		set @sql = 	  'select * into ' + @archivedb + '..scDrawForecasts '
		set @sql = @sql + ' from scDrawForecasts where dfdate between ''' + convert(nvarchar, @beginDate, 1) + ''' and ''' + convert(nvarchar, @endDate, 1)  + ''''
		print @sql 
		exec (@sql)

	--|  Delete: scDrawForecasts
		delete from scDrawForecasts
		where dfdate between @beginDate and @endDate
		set @count = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scDrawForecasts]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )

	--|  Archive:  scManifestUploadData
		set @sql = 	  'select * into ' + @archivedb + '..scManifestUploadData '
		set @sql = @sql + ' from scManifestUploadData where exists ( select * from scmanifesthistory his where scmanifestuploaddata.manifestid = his.manifestid and scmanifestuploaddata.manifesthistoryid = his.manifesthistoryid and mheffectivedate between ''' + convert(nvarchar, @beginDate, 1) + ''' and ''' + convert(nvarchar, @endDate, 1)  + ''')'
		print @sql 
		exec (@sql)

	--|  Delete:  scManifestUploadData
		delete from scManifestUploadData
		where exists ( 
			select *
			from scmanifesthistory his
			where scmanifestuploaddata.manifestid = his.manifestid
			and scmanifestuploaddata.manifesthistoryid = his.manifesthistoryid
			and mheffectivedate between @beginDate and @endDate
			)
		set @count = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scManifestUploadData]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src


	--|  Archive:  scManifestHistory
		set @sql = 	  'select * into ' + @archivedb + '..scManifestHistory '
		set @sql = @sql + ' from scManifestHistory where mheffectivedate between ''' + convert(nvarchar, @beginDate, 1) + ''' and ''' + convert(nvarchar, @endDate, 1)  + ''''
		print @sql 
		exec (@sql)

	--|  Delete:  scManifestHistory
		delete from scManifestHistory
		where mheffectivedate between @beginDate and @endDate
		set @count = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scManifestHistory]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )

	--|  Delete:  syncSystemLog
		set @sql = 	  'select * into ' + @archivedb + '..syncSystemLog '
		set @sql = @sql + ' from syncSystemLog where sltimestamp between ''' + convert(nvarchar, @beginDate, 1) + ''' and ''' + convert(nvarchar, @endDate, 1)  + ''''
		print @sql 
		exec (@sql)

	--|  Archive:  syncSystemLog
		delete from syncSystemLog
		where sltimestamp between @beginDate and @endDate	
		set @count = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [syncSystemLog]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  Shrink
		dbcc shrinkdatabase( @name, truncateonly )

  -----------------------------------
--| scManifestDownloadCancellations |
  -----------------------------------
	if exists (select name from sysobjects where name = N'scManifestDownloadCancellations' and type = 'U' )
	begin
		set @sql = 'select cxl.* into ' + @archivedb + '..scManifestDownloadCancellations '
		set @sql = @sql + ' from scManifestDownloadCancellations cxl
							join scManifestTransfers trx
							on trx.ManifestTransferId = cxl.ManifestTransferId 
							where mfstdate between  ''' + convert(nvarchar, @beginDate, 1) + ''' and ''' + convert(nvarchar, @endDate, 1)  + ''''
		print @sql 
		exec (@sql)
 		
		delete from scManifestDownloadCancellations
		where exists (
			select *
			from scmanifesttransfers trx
			where scmanifestdownloadcancellations.manifesttransferid = trx.manifesttransferid
			and mfstdate between @beginDate and @endDate
			)
		set @count = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scManifestDownloadCancellations]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src
		end

  ------------------------
--| scManifestDownladTrx |
  ------------------------
	if exists (select name from sysobjects where name = N'scManifestDownloadTrx' and type = 'U' )
	begin
		set @sql = 'select cxl.* into ' + @archivedb + '..scManifestDownloadTrx '
		set @sql = @sql + ' from scManifestDownloadTrx cxl
							where manifestdate between  ''' + convert(nvarchar, @beginDate, 1) + ''' and ''' + convert(nvarchar, @endDate, 1)  + ''''
		print @sql 
		exec (@sql)

		delete from scManifestDownloadTrx
		where manifestdate between @beginDate and @endDate
		set @count = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scManifestDownloadTrx]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src
	end

  ---------------------------
--| scManifestTransferDrops |
  ---------------------------
	if exists (select name from sysobjects where name = N'scManifestTransferDrops' and type = 'U' )
	begin
		set @sql = 'select drp.* into ' + @archivedb + '..scManifestTransferDrops '
		set @sql = @sql + ' from scManifestTransferDrops drp
							join scManifestTransfers xfer
							on xfer.ManifestTransferId = drp.ManifestTransferId
							where xfer.mfstdate between  ''' + convert(nvarchar, @beginDate, 1) + ''' and ''' + convert(nvarchar, @endDate, 1)  + ''''
		print @sql 
		exec (@sql)

		delete from scManifestTransferDrops
		where exists (
			select *
			from scmanifesttransfers xfer
			where scmanifesttransferdrops.manifesttransferid = xfer.manifesttransferid
			and xfer.mfstdate between @beginDate and @endDate
		)
		set @count = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scManifestTransferDrops]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src
	end

  ------------------------
--| scManifestTransfers  |
  ------------------------
	if exists (select name from sysobjects where name = N'scManifestTransfers' and type = 'U' )
	begin
		set @sql = 'select * into ' + @archivedb + '..scManifestTransfers '
		set @sql = @sql + ' from scManifestTransfers xfer
							where xfer.mfstdate between  ''' + convert(nvarchar, @beginDate, 1) + ''' and ''' + convert(nvarchar, @endDate, 1)  + ''''
		print @sql 
		exec (@sql)

		delete from scManifestTransfers
		where mfstdate between @beginDate and @endDate
		set @count = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scManifestTransfers]'
		print @msg
		exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src
	end

/*
  ------------------------
--| scDropHistory        |
  ------------------------
	delete from scDropHistory
	where exists ( 
		select *
		from scmanifesthistory his
		where scDropHistory.manifestid = his.manifestid
		and scDropHistory.manifesthistoryid = his.manifesthistoryid
		and mheffectivedate between @beginDate and @endDate
		)
	set @count = @@rowcount
	set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scDropHistory]'
	exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

  ---------------------------
--| scConditionHistory      |
  ---------------------------
	delete from scConditionHistory
	where DrawId in (
		select DrawId
		from #archive
		)
	set @count = @@rowcount
	set @msg = @src + ': Deleted ' + cast(@count as nvarchar) + ' rows from [scConditionHistory]'
	exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src
*/


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
