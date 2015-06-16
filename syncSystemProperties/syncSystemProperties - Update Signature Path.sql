
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
		set sysPropertyValue=''C:\Program Files\Syncronex\DataExchange\ToCircSystem\Signatures\' + @company_name + '''
		where sysPropertyName=''SignatureFilePath'''
	print @sql
	exec(@sql)

	set @sql = '
		select sysPropertyName, sysPropertyValue
		from ' + @company_catalog + '..syncSystemProperties
		where sysPropertyName=''SignatureFilePath''
		'
	exec(@sql)

	fetch next from company_cursor into @company_name, @company_catalog 
end

close company_cursor
deallocate company_cursor

/*
select *
from nsdb..syncSystemProperties
*/

commit tran
