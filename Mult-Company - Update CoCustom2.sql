begin tran

set nocount on

declare @company_id varchar(2)
declare @company_name varchar(50)
declare @company_catalog varchar(50)
declare @sql varchar(4096)

declare company_cursor cursor
for
	select CompanyId, CoName, CoDbCatalog
	from NSSESSION..nsSessionCompanies

open company_cursor
fetch next from company_cursor into @company_id, @company_name, @company_catalog 
while @@fetch_status = 0
begin
	print @company_name

	set @sql = 'use ' + @company_catalog + ' update nscompanies set cocustom2=''' + @company_name + ' (CompanyId=' + @company_id + ')'''
	exec(@sql)
	
	set @sql = '
		select *
		from ' + @company_catalog + '..nscompanies'
	exec(@sql)

	fetch next from company_cursor into @company_id, @company_name, @company_catalog 
end

close company_cursor
deallocate company_cursor

commit tran