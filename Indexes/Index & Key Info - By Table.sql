declare @objectName	varchar(256)
declare @obj varchar(256)

set @objectname = 'scDefaultDraws'

create table #indexes (
	  IndexName nvarchar(256)
	, IndexDescription nvarchar(1024)
	, IndexKeys nvarchar(2048)
)
insert into #indexes
exec sp_helpindex @objectName

declare fo_cursor cursor
for
	SELECT distinct fo.name
	FROM sys.foreign_keys k
	join sys.sysindexes i
		on k.referenced_object_id = i.id
		and k.key_index_id = i.indid
	join sysobjects o
		on k.parent_object_id = o.id
	join sysobjects fo
		on i.id = fo.id
	WHERE [parent_object_id] = OBJECT_ID( @objectName ) 

open fo_cursor
fetch next from fo_cursor into @obj
while @@fetch_status = 0
begin
	--print @objectName
	insert into #indexes
	exec sp_helpindex @obj

	fetch next from fo_cursor into @obj
end

		
SELECT o.name as [Object], k.name as [Index/Constraint], i.name as [ForeignIndex/Constraint]
	, tmp.IndexKeys
FROM sys.foreign_keys k
join sys.sysindexes i
	on k.referenced_object_id = i.id
	and k.key_index_id = i.indid
join sysobjects o
	on k.parent_object_id = o.id
full outer join #indexes tmp
	on i.[name]	= tmp.IndexName
WHERE [parent_object_id] = OBJECT_ID( @objectName )
union	
select o.[name], i.[name], null
	, tmp.IndexKeys
from sysindexes i
join sysobjects o
	on i.id = o.id
join #indexes tmp
	on i.[name]	= tmp.IndexName
where o.type = 'u'
and o.[name] = @objectname
--order by o.[name]

close  fo_cursor
deallocate fo_cursor

drop table #indexes

