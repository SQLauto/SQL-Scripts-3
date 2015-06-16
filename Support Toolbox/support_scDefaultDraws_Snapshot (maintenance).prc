begin tran

select [name]
from sysobjects
where name like 'scDefaultDraws_Snapshot%'
and type = 'U'


declare @sql nvarchar(1000)

declare dropTable_Cursor cursor
for
	select 'Drop Table ' + [name]
	from sysobjects
	where name like 'scDefaultDraws_Snapshot%'
	and type = 'U'
	--and datediff(d, getdate(), crdate)  < -7
	and datediff(d, '4/6/2013', crdate)  < 0

open dropTable_Cursor 
fetch next from dropTable_Cursor into @sql
while @@fetch_status = 0
begin
	
	print @sql
	exec(@sql)
	fetch next from dropTable_Cursor into @sql
end	

close dropTable_Cursor
deallocate dropTable_Cursor


rollback tran