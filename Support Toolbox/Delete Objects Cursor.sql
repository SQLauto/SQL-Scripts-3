begin tran

declare @preview int
set @preview = 1

declare @counter int
set @counter = 0

declare @sql nvarchar(1000)

declare dropTable_Cursor cursor
for
	select 'Drop Table ' + [name]
	from sysobjects
	where name like 'support%'
	and type = 'U'
	--and datediff(d, getdate(), crdate)  < -7
	and datediff(d, dateadd(d, -1, getdate()), crdate)  < 0
	order by crdate desc
	
open dropTable_Cursor 
fetch next from dropTable_Cursor into @sql
while @@fetch_status = 0
begin
	
	if @preview = 1
	begin
		print @sql
	end
	else
	begin
		print @sql
		exec (@sql)
	end

	set @counter = @counter + 1
	
	fetch next from dropTable_Cursor into @sql
end	

close dropTable_Cursor
deallocate dropTable_Cursor

print cast(@counter as nvarchar) + ' objects'


commit tran