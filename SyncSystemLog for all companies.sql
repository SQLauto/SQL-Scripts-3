set nocount on

declare @company_name varchar(50)
declare @company_catalog varchar(50)
declare @sql varchar(4096)

declare company_cursor cursor
for
	select CoName, CoDbCatalog
	from NSSESSION..nsSessionCompanies
	order by CoName

open company_cursor
fetch next from company_cursor into @company_name, @company_catalog 
while @@fetch_status = 0
begin
	set @sql = '
		select ''' + @company_name + ''' as [Company], sltimestamp, logmessage
		from ' + @company_catalog + '..syncSystemLog
		where logmessage like (''%forecast%'')
		and datediff(d, sltimestamp, getdate()) = 0'
	exec(@sql)

	fetch next from company_cursor into @company_name, @company_catalog 
end

close company_cursor
deallocate company_cursor

