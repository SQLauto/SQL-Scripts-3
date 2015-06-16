set nocount on

begin tran

declare @objname varchar(100)
set @objname = '%support%'

declare @obj varchar(100)
declare @sql varchar(1000)

select [name]
from sysobjects
where [name] like @objname
and [type] = 'u'

declare cleanup_cursor cursor
for 
	select [name]
	from sysobjects
	where [name] like @objname
	and [type] = 'u'
	
open cleanup_cursor 
fetch next from cleanup_cursor into @obj

while @@FETCH_STATUS = 0
begin
	set @sql = 'drop table [' + @obj + ']'
	print 'dropping table [' + @obj + ']'
	exec(@sql)	


	fetch next from cleanup_cursor into @obj
end

close cleanup_cursor
deallocate cleanup_cursor

select [name]
from sysobjects
where [name] like @objname
and [type] = 'u'

commit tran