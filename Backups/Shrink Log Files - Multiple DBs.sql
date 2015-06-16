set nocount on

declare @name sysname,
    @file_id int,
    @sql varchar(max)

declare db_cursor cursor
for
	select d.name, mf.file_id
	from master.sys.databases d
	join master.sys.master_files mf
		on d.database_id = mf.database_id
	where ( 
		d.[name] like '%prod'
		--or d.[name] like '%stage' 
		)
	and mf.type = 1 --0 is data, 1 is log
	and mf.size * 8 / 1024 > 1
	--and physical_name like 'C:\%'

open db_cursor
fetch next from db_cursor into @name, @file_id

while @@fetch_status = 0 
begin

	print 'shrinking log file for '+ QUOTENAME(@name) + '...'
    set @sql = 'use ' + QUOTENAME(@name) + '; checkpoint; dbcc shrinkfile ( ' + cast(@file_id as varchar) + ', 1024 );'
    exec ( @sql )

    fetch next from db_cursor into @name, @file_id
end

close db_cursor
deallocate db_cursor
go