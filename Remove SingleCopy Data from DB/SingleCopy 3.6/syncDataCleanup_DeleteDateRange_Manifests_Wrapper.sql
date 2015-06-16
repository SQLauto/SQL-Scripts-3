	set nocount on

	select min(ManifestDate) as [minManifestDate]
	from scManifests

	--declare @retentionPeriod int
	--set @retentionPeriod = 6  --|months

	declare @chunk int
	set @chunk = 4

	declare @minDate datetime
	
	select @minDate = min(ManifestDate)
	from scManifests

	declare @thresholdDate datetime

	set @thresholdDate = '8/3/2014'
	--set @thresholdDate = dateadd(d, 1, @minDate)
	print @thresholdDate

	CREATE TABLE #helpdb (		[name] nvarchar(100)
		,[dbsize] nvarchar(25)
		,[owner] nvarchar(25) null
		,[dbid] int
		,[created] datetime
		,[status] nvarchar(256)
		,[compatiblity_level] int
	   )

	INSERT INTO #helpdb
	EXEC sp_helpdb

	select 'database size is ' + [dbsize]
	from #helpdb
	where [name] = ( select db_name() )

	declare @tmpThreshold datetime

	while @minDate < @thresholdDate
	begin
		if ( dateadd(month, @chunk, @minDate) < @thresholdDate )
		begin
			set @tmpThreshold = dateadd(month, @chunk, @minDate)
			print 'Deleting data older than ' + convert(varchar, @tmpThreshold, 101) + '...'
			
			--select datediff( month, min(ManifestDate), @tmpThreshold) 
			--from scDraws

			exec syncDataCleanup_DeleteDateRange_Manifests @tmpThreshold

			set @mindate = dateadd(month, @chunk, @minDate)
		end
		else
		begin
			print 'Deleting data older than ' + convert(varchar, @thresholdDate, 101) + '...'

			--select datediff( month, min(ManifestDate), @thresholdDate) 
			--from scDraws

			exec syncDataCleanup_DeleteDateRange_Manifests @thresholdDate

			set @mindate = @thresholdDate
		end

	end

	select min(ManifestDate) as [minManifestDate]
	from scManifests

	TRUNCATE TABLE #helpdb	
	INSERT INTO #helpdb
	EXEC sp_helpdb

	select 'database size is ' + [dbsize]
	from #helpdb
	where [name] = ( select db_name() )

	drop table #helpdb