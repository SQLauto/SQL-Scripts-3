

/*
Compare the data between the two tables
*/

begin tran

set nocount on

select name
into #nsdbtables
from nsdb..sysobjects obj
where type = 'U'
and name <> 'dtproperties'
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

declare @sql varchar(4048)
declare @where varchar(4048)
declare @name varchar(50)
declare @colname varchar(50)
declare @colid int
declare @maxcol int

declare obj_cursor cursor
for
	select tablename
	from #tables

open obj_cursor
fetch next from obj_cursor into @name

while @@fetch_status = 0
begin
	select @maxcol = max(colid)
	from syscolumns
	where id = object_id(@name)

	set @sql = 'select *
				from nsdb..' + @name + ' nsdb
				join nsdb26..' + @name + ' nsdb26 on '
	set @where = 'where '
	declare col_cursor cursor
	for
		select syscol.name, syscol.colid
		from syscolumns syscol
		join systypes systyp
		on syscol.xtype = systyp.xtype
		where syscol.id = object_id(@name)
		and systyp.name in ('nvarchar', 'int', 'nchar')
		order by colid

	open col_cursor
	fetch next from col_cursor into @colname, @colid
	while @@fetch_status = 0
	begin
		if @colid between 2 and @maxcol + 1
		begin
			set @sql = @sql + ' and '
			set @where = @where + ' or '			
		end
		set @sql = @sql + ' nsdb.' + @colname + ' = nsdb26.' + @colname + ' '
		set @where = @where + ' nsdb.' + @colname + ' <> nsdb26.' + @colname + ' '
	fetch next from col_cursor into @colname, @colid
	end
	
	set @sql = @sql + @where
	exec(@sql)
	print @sql

	close col_cursor
	deallocate col_cursor

	fetch next from obj_cursor into @name
end
close obj_cursor
deallocate obj_cursor

drop table #tables

rollback tran

/*
select *
from nsdb..dd_nsChangeTypes nsdb
join nsdb26..dd_nsChangeTypes nsdb26 on  nsdb.ChangeTypeID = nsdb26.ChangeTypeID  and  nsdb.ChangeTypeName = nsdb26.ChangeTypeName  and  nsdb.ChangeTypeDescription = nsdb26.ChangeTypeDescription  and nsdb.System = nsdb26.System 
*/