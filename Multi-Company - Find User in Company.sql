
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

	set @sql = 'use ' + @company_catalog
	 + ' 
		select username as [' + @company_catalog + ']
		from users
		where username = ''paul.rochon@sunmedia.ca''

'

	print @sql
	exec(@sql)

	fetch next from company_cursor into @company_name, @company_catalog 
end

close company_cursor
deallocate company_cursor

rollback tran

/*

select *
from nsdb..syncSystemProperties

*/