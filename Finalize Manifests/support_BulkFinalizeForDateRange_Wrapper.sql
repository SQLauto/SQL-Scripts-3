	declare @chunkStartDate datetime
	declare @chunkEndDate datetime
	declare @msg nvarchar(200)
	declare @refinalize int 

	declare @threshold datetime

	--set @threshold = '1/1/2012'
	set @threshold = convert(varchar, dateadd(year, -3, getdate()), 1)

		declare @chunk int
	set @chunk = -1

		select @chunkEndDate = dateadd(d, -1, min(ManifestDate))
		from scManifests
		
		select @chunkStartDate = dateadd(month, -1, min(ManifestDate))
		from scManifests
		
		
		while @chunkStartDate >= @threshold
		begin
			if ( @chunkStartDate > @threshold )
			begin
				print 'bulk finalizing for ' + convert(varchar, @chunkStartDate, 101) + ' through ' + convert(varchar, @chunkEndDate, 101)			
				exec support_BulkFinalizeForDateRange @startdate=@chunkStartDate, @enddate=@chunkEndDate, @refinalize=0
				
				select @chunkEndDate = dateadd(d, -1, min(ManifestDate))
				from scManifests
				
				select @chunkStartDate = dateadd(month, @chunk, min(ManifestDate))
				from scManifests
	
		
			end
			else
			begin
				set @chunkStartDate = @threshold
				print 'bulk finalizing for ' + convert(varchar, @chunkStartDate, 101) + ' through ' + convert(varchar, @chunkEndDate, 101)						
				
				exec support_BulkFinalizeForDateRange @startdate=@chunkStartDate, @enddate=@chunkEndDate, @refinalize=0
				
				select @chunkEndDate = dateadd(d, -1, min(ManifestDate))
				from scManifests
				
				select @chunkStartDate = dateadd(month, @chunk, min(ManifestDate))
				from scManifests
			end

		end
