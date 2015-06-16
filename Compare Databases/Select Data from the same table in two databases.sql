

/*


Compare the data between the two tables
*/

begin tran

select name
into #nsdbtables
from nsdb..sysobjects obj
where type = 'U'
order by name

select name
into #nsdb26tables
from nsdb26..sysobjects obj
where type = 'U'
order by name

select a.name as [tablename]
into #tables
from #nsdbtables a
full outer join #nsdb26tables b
on a.name = b.name
where a.name is not null and b.name is not null

drop table #nsdbtables
drop table #nsdb26tables

declare @sql varchar(1024)
declare @name varchar(50)

declare obj_cursor cursor
for
	select tablename
	from #tables

open obj_cursor
fetch next from obj_cursor into @name

while @@fetch_status = 0
begin

	
	set @sql  = ' declare @count int select @count = count(*) from nsdb..' + @name + ' if @count <> 0 begin select * from nsdb..' + @name
				+ ' select * from nsdb26..' + @name + ' end'
	exec(@sql)

	fetch next from obj_cursor into @name
end
close obj_cursor
deallocate obj_cursor

drop table #tables

rollback tran