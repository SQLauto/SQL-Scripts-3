
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

--|Returns/Adjustments Export Config Path
	set @sql = 'use ' + @company_catalog + ' update syncSystemProperties 
		set sysPropertyValue=''C:\Program Files\Syncronex\SingleCopy\DataIO\' + @company_name + '_ExportConfig.xml''
		where sysPropertyName=''ExportConfigFilePath'''
	exec(@sql)

--|Invoice Export Config Path
	set @sql = 'use ' + @company_catalog + ' update syncSystemProperties 
		set sysPropertyValue=''C:\Program Files\Syncronex\SingleCopy\DataIO\' + @company_name + '_InvoiceExportConfig.xml''
		where sysPropertyName=''InvoiceExportConfigFilePath'''
	exec(@sql)

	set @sql = '
		select ''' + @company_name + ''' as [Company], sysPropertyName, sysPropertyValue
		from ' + @company_catalog + '..syncSystemProperties
		where sysPropertyName=''ExportConfigFilePath''
		or sysPropertyName=''InvoiceExportConfigFilePath''
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