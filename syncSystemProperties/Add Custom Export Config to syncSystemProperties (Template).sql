begin tran

set nocount on

declare @exportTypeBitwise int --[1=Returns|2=Adjustments|3=Returns&Adjustments]

set @exportTypeBitwise = 4 --[1=Returns|2=Adjustments|3=Returns&Adjustments|4=Forecast]


declare @CustomExportName nvarchar(50)
declare @CustomExportDescription nvarchar(128)
declare @CustomExportConfigFileName nvarchar(512)

/*----------------------------------------------------------------------


	@CustomExportName:  Must have CustomExportConfigFile prefix
	@CustomExportDescription:  Displayed in export drop-down list
	@CustomExportConfigFileName:  

----------------------------------------------------------------------*/
set @CustomExportName = 'CustomExportConfigFile' 
		+ case @exportTypeBitwise
			when 1 then '_Returns'
			when 2 then '_Adjustments'
			when 3 then '_RetursAdjustments'
			when 4 then '_Forecast'
			end
	set @CustomExportDescription = 'Custom Export: '
			+ case @exportTypeBitwise
			when 1 then 'Returns'
			when 2 then 'Adjustments'
			when 3 then 'RetursAdjustments'
			when 4 then 'Forecast'
			end
	set @CustomExportConfigFileName = 'CustomExport'
			+ case @exportTypeBitwise
			when 1 then '_Returns'
			when 2 then '_Adjustments'
			when 3 then '_RetursAdjustments'
			when 4 then '_Forecast'
			end + '.xml'
			
	if exists (
		select 1 
		from syncSystemProperties
		where SysPropertyValue = @CustomExportConfigFileName
	)
	begin
		update syncSystemProperties
		set SysPropertyName = @CustomExportName
			, SysPropertyDescription = @CustomExportDescription
		where SysPropertyValue = @CustomExportConfigFileName

			if @@rowcount > 0
				print 'Custom Export ''' + @CustomExportName + ''' already exists.  Updated config file to ' + @CustomExportConfigFileName
			else
				print 'Custom Export ''' + @CustomExportName + ''' already exists with value ''' + @CustomExportConfigFileName + ''''
	end
	else
	begin
		insert into syncSystemProperties ( SystemPropertyId, SysPropertyName, SysPropertyDescription, SysPropertyValue, Display )
		select 
			max(SystemPropertyId) + 1							as [Id]
			, @CustomExportName									as [Name]
			, @CustomExportDescription							as [Description]  
			, @CustomExportConfigFileName						as [Value]
			, 0													as [Display]
		from syncSystemProperties
		
		if @@rowcount > 0
		begin
			print 'Successfully added Custom Export: '
			print '  @CustomExportName:  ' + @CustomExportName
			print '  @CustomExportDescription:  ' + @CustomExportDescription
			print '  @CustomExportConfigFileName:  ' + @CustomExportConfigFileName
		end	
	end	
	
--select *
--from syncSystemProperties
--where SysPropertyName like 'CustomExport%'

print 'SyncExport.exe Custom "E:\Program Files (x86)\Syncronex\SingleCopy\DataIO\Export_roa\' + @CustomExportConfigFileName + '" /p "StartDate=11/24/2013","StopDate=11/30/2013","UserID=1" /w '

--delete from syncSystemProperties
--where SystemPropertyId = 89

rollback tran