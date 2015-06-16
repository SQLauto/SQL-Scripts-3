--|Reseed Tables with Identity Columns
declare @sql varchar(1024)
declare @name varchar(50)
declare @colname varchar(50)
declare @ident int

select sysobj.name as [tablename], syscol.name as [colname]
into #identcols
from syscolumns syscol
join systypes systyp
	on syscol.xtype = systyp.xtype
join sysobjects sysobj
	on syscol.id = sysobj.id
where sysobj.type = 'U'
and syscol.colstat = 1

--/*
declare ident_cursor cursor
for 
select *
from #identcols

open ident_cursor
fetch next from ident_cursor into @name, @colname
while @@fetch_status = 0
begin
print ''
print @name + '(' + @colname + ')'
print '---------------------------------------------------------------------------'
set @sql = 'declare @ident int select @ident = isnull( max(' + @colname + '), 1 ) from ' + @name + ' dbcc checkident (''' + @name + ''', reseed, @ident )' 
exec(@sql)

fetch next from ident_cursor into @name, @colname
end

close ident_cursor
deallocate ident_cursor

drop table #identcols