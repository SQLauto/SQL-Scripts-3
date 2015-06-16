declare @startDate	datetime
declare @endDate	datetime
declare @today		datetime

declare @cmd nvarchar(4000)

--set @today = cast( convert(nvarchar, getdate(), 1) as datetime )
set @today = cast( convert(nvarchar, '6/5/2011', 1) as datetime )

	if datepart( dw, @today ) = 2
	begin
		set @startDate = dateadd(d, -14, @today)
	end
	else
	begin
		while ( 1=1 )
		begin
			set @startDate = dateadd( d, -1, coalesce(@startDate,@today) )
			print '.' + cast(@startDate as varchar)
			if datepart(dw, @startDate) = 2
			begin
				print 'we have the most recent monday ' + cast(@startDate as varchar) 
				if datediff(d, @startDate, @today) < 14
				begin
					select dateadd(d, -14, @startDate)
					set @startDate = dateadd(d, -14, @startDate)
				end	
				else
				begin
					select dateadd(d, -14, @startDate)
					set @startDate = dateadd(d, -14, @startDate)
				end
				break
			end	
		end
	end


print @startDate
/*
	Start Date is Monday of the previous billing period.
		
	Data Entry closes on Friday	
	

*/

/*
set @startDate = dateadd( dd, 10, @today )
set @endDate = DATEADD( dd, 16, @today )


set @Cmd = 'D:\Syncronex\bin\syncExport.exe forecast "D:\Program Files\Syncronex\SingleCopy\DATAIO\WeeklyForecastExport.xml" /p StartDate="'
     + CONVERT(NVARCHAR(10),@firstdate,101)
	 + '",StopDate="'
	 + CONVERT(NVARCHAR(10),@lastdate,101)
	 + '"'

EXECUTE  master..xp_cmdshell  @Cmd
*/

