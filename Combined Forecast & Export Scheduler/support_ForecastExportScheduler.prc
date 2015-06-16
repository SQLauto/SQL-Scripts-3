IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_ForecastExportScheduler]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_ForecastExportScheduler]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[support_ForecastExportScheduler]
	  @beginDateOffset int
	, @endDateOffset int
	, @runonday varchar(9) = null
	, @pubFrequency int = null
	, @exportType varchar(9)		--|[Return|Adjustment|Forecast|Custom|Invoice]
	, @pathToConfigFile nvarchar(1000)
	, @configFile nvarchar(100)
	, @delay_seconds int = null	

AS
BEGIN
	set nocount on

	declare @msg varchar(256)
	declare @today datetime
	declare @exportLocked bit
	declare @userId int
	declare @startdate nvarchar(10)
	declare @stopdate nvarchar(10)
	declare @args nvarchar(512)
	declare @delay nvarchar(8)
	
	set @today = GETDATE()
	
	--|validation
	if @exportType not in (
		select replace(ExportTypeDescription, ' Export', '')
		from dd_scExportTypes
		)
	begin
		set @msg = 'invalid export type ''' + @exportType + ''''
		exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
		print @msg
		return
	end

	if ( ( @runonday is not null ) and ( datename( dw, @today) <> @runonday ) )
	begin
		set @msg = 'This job is configured to run relative to ' + @runonday + ' but today is ' + DATENAME(dw, @today) + '.'  
		exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
		print @msg
		return
	end

	--|  BeginDate must be less than EndDate
	if ( DATEADD(d, @beginDateOffset, @today) > DATEADD(d, @endDateOffset, @today) )
	begin
		set @msg = 'Begin Date ''' + convert(varchar, DATEADD(d, @beginDateOffset, @today), 1)
			 + ''' is not earlier than End Date ''' + convert(varchar, DATEADD(d, @endDateOffset, @today), 1) + '''.'
		exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
		print @msg
		return
	end
	else 
	begin
		set @startdate = convert(varchar, DATEADD(d, @beginDateOffset, @today), 1)
		set @stopdate = convert(varchar, DATEADD(d, @endDateOffset, @today), 1)
		print 'StartDate: ' + convert(varchar, @startdate, 101)
		print 'StopDate: ' + convert(varchar, @stopdate, 101)
	end

	select @userId = isnull(UserId,0)
	from Users
	where UserName = 'admin@singlecopy.com'
	
	if ( right(@pathToConfigFile,1) <> '\' )
		set @pathToConfigFile = @pathToConfigFile + '\'
		
	--set @args = 'Custom "C:\Program Files (x86)\Syncronex\SingleCopy\DataIO\STATE\CustomExportForecast.xml" /p "StartDate=' + @startdate + '","StopDate=' + @stopdate + '","UserID=' + cast(@userId as varchar) + '"' 
	set @args = @exportType + ' "' + @pathToConfigFile + @configFile + '" /p "StartDate=' +  + @startdate + '","StopDate=' + @stopdate + '","UserID=' + cast(@userId as varchar) + '"' 

	--| add pub filter by frequency
	if @pubFrequency is not null
	begin	
		declare @exclude varchar(max)
		select @exclude = COALESCE(@exclude+',' ,'') + 'PubShortName='+PubShortName
		from nsPublications p
		where p.PubFrequency & @pubFrequency = 0
		or p.PubCustom3 = 'ExcludeFromForecastExport'	
		order by p.PubShortName
		
		set @args = @args + ' /e ' + @exclude
	end	
	
	
	if @delay_seconds is not null
	begin
		--|  don't delay more than 1 hour (3600 seconds)
		if @delay_seconds between 1 and 3600
		begin
			set @delay = convert(varchar, dateadd(ms, @delay_seconds*1000,0), 114)
			print 'Delay: ' + @delay + ' (hh:mm:ss)'
		end
		else
		begin
			set @msg = 'Invalid value for delay interval (seconds).'
			exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
			print @msg
			return	
		end
		
		select @exportLocked = cast(running.SysPropertyValue as bit) | cast(requested.SysPropertyValue as bit)
		from (
			select SysPropertyValue
			from syncSystemProperties 
			where SysPropertyName = 'DataExportRunning'
			) as running
		join (
			select SysPropertyValue
			from syncSystemProperties 
			where SysPropertyName = 'RunDataExport'
			) as requested
		on 1 = 1

		while @exportLocked <> 0
		begin
			set @msg = 'An export is already running or has been requested to run, delaying ' + cast(@delay_seconds as nvarchar) + ' seconds.'
			exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
			print @msg
			
			waitfor delay @delay
			
			select @exportLocked = cast(running.SysPropertyValue as bit) | cast(requested.SysPropertyValue as bit)
			from (
				select SysPropertyValue
				from syncSystemProperties 
				where SysPropertyName = 'DataExportRunning'
				) as running
			join (
				select SysPropertyValue
				from syncSystemProperties 
				where SysPropertyName = 'RunDataExport'
				) as requested
			on 1 = 1
		end
	end

	--|  Run the export	

	update syncSystemProperties
	set SysPropertyValue = @args
	Where SysPropertyName = 'DataExportCommandArgs'

	set @msg = 'Setting export command arguments: ' + @args
	exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
	print @msg				

	waitfor delay @delay
				
	if exists (
		select 1
		from syncSystemProperties 
		Where SysPropertyName = 'DataExportCommandArgs'
		and SysPropertyValue = @args
	)
	begin 
		
		set @msg = 'Run Data Export'
		exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
		print @msg					

		update syncSystemProperties
		set SysPropertyValue = 'True'
		Where SysPropertyName = 'RunDataExport'
	end	

	--update syncSystemProperties
	--set SysPropertyValue =
	--	case 
	--		when SysPropertyName = 'DataExportCommandArgs'
	--			then @args
	--		when SysPropertyName = 'RunDataExport'
	--			then 'True'
	--	end
	--where SysPropertyName in ( 'DataExportCommandArgs', 'RundataExport' )	
		
	--| Insert an informational message into the System Log
	--set @msg = 'An export has been requested with arguments: ' + @args
	--exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
	--print @msg

END


GO

