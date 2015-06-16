IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'syncDataCleanup_DeleteDateRange_Draw' 
	   AND 	  type = 'P')
    DROP PROCEDURE dbo.syncDataCleanup_DeleteDateRange_Draw
GO

CREATE PROCEDURE dbo.syncDataCleanup_DeleteDateRange_Draw
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

	set @src = 'syncDataCleanup_DeleteDateRange'
	set @msg = @src + ': Procedure beginning with parameters: thresholdDate=' + convert(nvarchar, @thresholdDate, 1)
	print @msg
	--exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

  ---------------------------
--|	Database Statistics		|--
  ---------------------------
/*
	CREATE TABLE #helpdb (
		[name] nvarchar(100)
		,[dbsize] nvarchar(25)
		,[owner] nvarchar(25) null
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
	--exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src
*/
	
    set @msg = @src + ': Data older than ' + convert(nvarchar, @thresholdDate, 1) + ' will be Deleted.'
	print @msg
	--exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

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
		set @rowcount = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@rowcount as nvarchar) + ' rows from [scDrawAdjustmentsAudit]'
		print @msg
		--exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src
		
	--|  Shrink
		if @rowcount > 0
		begin 
			print 'shrinking database...'
			dbcc shrinkdatabase( @name, truncateonly ) WITH NO_INFOMSGS
		end

	--|  scReturns & scReturnsAudit
		delete from scReturnsAudit
		where DrawId in (
			select DrawId
			from #delete
			)
		set @rowcount = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@rowcount as nvarchar) + ' rows from [scReturnsAudit]'
		print @msg
		--exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  Shrink
		if @rowcount > 0
		begin 
			print 'shrinking database...'
			dbcc shrinkdatabase( @name, truncateonly ) WITH NO_INFOMSGS
		end

	--|  scDrawHistory
		delete from scDrawHistory
		where DrawId in (
			select DrawId
			from #delete
			)
		set @rowcount = @@rowcount
		set @msg = @src + ': Deleted ' + cast(@rowcount as nvarchar) + ' rows from [scDrawHistory]'
		print @msg
		--exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  scDraws
		delete from scDraws
		where DrawId in (
			select DrawId
			from #delete
			)
		set @rowcount = @@rowcount
			set @msg = @src + ': Deleted ' + cast(@rowcount as nvarchar) + ' rows from [scDraws]'
		print @msg
		--exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	--|  Shrink
		if @rowcount > 0
		begin 
			print 'shrinking database...'
			dbcc shrinkdatabase( @name, truncateonly ) WITH NO_INFOMSGS
		end

/*
	truncate table #helpdb
	insert into #helpdb
	exec sp_helpdb

	select @dbname = [name]
			,@dbsize = [dbsize]
	from #helpdb
	where [name] = ( select db_name() )
	
	set @msg = @src + ': database size is ' + @dbsize
	print @msg
		--exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src

	drop table #helpdb
*/
	set @msg = @src + ': Procedure Completed'
	print @msg
	--exec syncSystemLog_Insert @ModuleID = 1, @SeverityID = 2, @CompanyID = 1, @Message = @msg, @GroupID = null, @ProcessID = null, @ThreadID = null, @DeviceId = null, @UserId = null, @Source = @src
GO