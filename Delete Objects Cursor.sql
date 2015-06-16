
declare @keyword nvarchar(50)
declare @preview int

set @preview = 1
set @keyword = '%rollback%'

declare obj_cursor cursor
for 
	select id, name
	from sysobjects
	where name like '%' + @keyword + '%'
	and type = 'U'


declare @id int
declare @name nvarchar(255)
declare @sql nvarchar(1000)

open obj_cursor
fetch next from obj_cursor into @id, @name

while @@FETCH_STATUS = 0
begin
	
	set @sql = 'drop table [dbo].[' + @name + ']'
	if @preview = 0
	begin
		exec(@sql)
		print 'dropped table ' + @name
	end
	else
	begin
		print @name
	end
	

fetch next from obj_cursor into @id, @name
end

close obj_cursor
deallocate obj_cursor


