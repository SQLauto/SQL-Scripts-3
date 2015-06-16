	set nocount on

	select min(DrawDate) as [minDrawDate]
	from scDraws

	declare @retentionPeriod int
	set @retentionPeriod = 6  --|months

	declare @chunk int
	set @chunk = 4

	declare @minDate datetime
	
	select @minDate = min(DrawDate)
	from scDraws

	declare @thresholdDate datetime
	select @thresholdDate = convert(varchar, dateadd(month, -1*@retentionPeriod, getdate()), 1)
	print @thresholdDate

	declare @tmpThreshold datetime

	while @minDate < @thresholdDate
	begin
		if ( dateadd(month, @chunk, @minDate) < @thresholdDate )
		begin
			set @tmpThreshold = dateadd(month, @chunk, @minDate)
			print 'Deleting data older than ' + convert(varchar, @tmpThreshold, 101) + '...'
			
			--select datediff( month, min(DrawDate), @tmpThreshold) 
			--from scDraws

			exec syncDataCleanup_DeleteDateRange @tmpThreshold

			set @mindate = dateadd(month, @chunk, @minDate)
		end
		else
		begin
			print 'Deleting data older than ' + convert(varchar, @thresholdDate, 101) + '...'

			--select datediff( month, min(DrawDate), @thresholdDate) 
			--from scDraws

			exec syncDataCleanup_DeleteDateRange @thresholdDate

			set @mindate = @thresholdDate
		end

	end

	select min(DrawDate) as [minDrawDate]
	from scDraws
