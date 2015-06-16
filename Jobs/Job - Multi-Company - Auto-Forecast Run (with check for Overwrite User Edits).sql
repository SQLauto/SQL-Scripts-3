
set nocount on

declare @company_name varchar(50)
declare @company_catalog varchar(50)
declare @sql varchar(4096)

declare company_cursor cursor
for
	select CoName, CoDbCatalog
	from NSSESSION..nsSessionCompanies

open company_cursor
fetch next from company_cursor into @company_name, @company_catalog 
while @@fetch_status = 0
begin
	print @company_name

	set @sql = 'use ' + @company_catalog + 'update merc_ControlPanel 
			set AttributeValue = ''false'' 
			where AttributeName = ''OverwriteUserEdits'' 
			and AppLayer = ''ForecastEngine'' 
			 
			exec scForecastEngine_Run @DaysFromNow=1, @LoggingLevel=-1, @LogFile=Null, @Diagnostic=False'
	exec(@sql)

	fetch next from company_cursor into @company_name, @company_catalog 	
end

close company_cursor
deallocate company_cursor
