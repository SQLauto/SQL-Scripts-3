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
	 + ' select sltimestamp, logmessage as [' + @company_name + '] 
		from syncsystemlog
		where datediff(d, sltimestamp, getdate()) = 0 
		and ( logmessage like ''processing for%''  
		or logmessage like ''%final%''
		or logmessage like ''%split%''
		)
		order by sltimestamp desc'
	exec(@sql)
	
	fetch next from company_cursor into @company_name, @company_catalog 
end

close company_cursor
deallocate company_cursor

rollback tran