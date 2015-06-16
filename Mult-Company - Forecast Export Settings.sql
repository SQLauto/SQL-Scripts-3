
begin tran

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

--|Forecast Export Config Path
	set @sql = 'use ' + @company_catalog + ' update syncSystemProperties 
		set sysPropertyValue=''C:\Program Files\Syncronex\SingleCopy\DataIO\' + @company_name + '\DailyForecastExport.xml''
		where sysPropertyName=''DataExportConfigFile'''
	print @sql
	exec(@sql)

--|Forecast Export Engine Path
	set @sql = 'use ' + @company_catalog + ' update syncSystemProperties 
		set sysPropertyValue=''C:\Program Files\Syncronex\SingleCopy\bin\SyncExport.exe''
		where sysPropertyName=''DataExportEnginePath'''
	print @sql
	exec(@sql)

	set @sql = '
		select sysPropertyName, sysPropertyValue
		from ' + @company_catalog + '..syncSystemProperties
		where sysPropertyName=''DataExportConfigFile''
		or sysPropertyName=''DataExportEnginePath''
		'
	exec(@sql)

	fetch next from company_cursor into @company_name, @company_catalog 
end

close company_cursor
deallocate company_cursor

commit tran

/*

select *
from nsdb..syncSystemProperties

*/