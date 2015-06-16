	set nocount on

	select min(DrawDate) as [minDrawDate]
	from scDraws

	--declare @retentionPeriod int
	--set @retentionPeriod = 6  --|months

	declare @chunk int
	set @chunk = 4

	declare @minDate datetime
	
	select @minDate = min(DrawDate)
	from scDraws

	declare @thresholdDate datetime

	set @thresholdDate = '1/1/2009'
	--set @thresholdDate = dateadd(d, 14, @minDate)
	print @thresholdDate

	CREATE TABLE #helpdb (		[name] nvarchar(100)
		,[dbsize] nvarchar(25)
		,[owner] nvarchar(25) null
		,[dbid] int
		,[created] datetime
		,[status] nvarchar(256)
		,[compatiblity_level] int
	   )

	--INSERT INTO #helpdb
	--EXEC sp_helpdb

	--select 'database size is ' + [dbsize]
	--from #helpdb
	--where [name] = ( select db_name() )

	declare @tmpThreshold datetime

	while @minDate < @thresholdDate
	begin
		if ( dateadd(month, @chunk, @minDate) < @thresholdDate )
		begin
			set @tmpThreshold = dateadd(month, @chunk, @minDate)
			print 'Deleting data older than ' + convert(varchar, @tmpThreshold, 101) + '...'
			
			exec syncDataCleanup_DeleteDateRange_Draw @tmpThreshold

			set @mindate = dateadd(month, @chunk, @minDate)
		end
		else
		begin
			print 'Deleting data older than ' + convert(varchar, @thresholdDate, 101) + '...'

			exec syncDataCleanup_DeleteDateRange_Draw @thresholdDate

			set @mindate = @thresholdDate
		end

	end

	select min(DrawDate) as [minDrawDate]
	from scDraws

	--TRUNCATE TABLE #helpdb	
	INSERT INTO #helpdb
	EXEC sp_helpdb

	select 'database size is ' + [dbsize]
	from #helpdb
	where [name] = ( select db_name() )

	drop table #helpdb
