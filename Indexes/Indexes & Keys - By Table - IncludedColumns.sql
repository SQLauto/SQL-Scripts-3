declare @includedColumns table ( [ObjId] int, IndexId int, IndexName nvarchar(256), ColName nvarchar(256) )
declare @indexes table ( IndexName nvarchar(256), IndexDescription nvarchar(1024), IndexKeys nvarchar(2048) )

declare @objectName	varchar(256)
declare @obj varchar(256)

set @objectname = 'scReturnsAudit'

insert into @indexes
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
	insert into @indexes
	exec sp_helpindex @obj

	fetch next from fo_cursor into @obj
end

close  fo_cursor
deallocate fo_cursor


insert into @includedColumns
select o.id, i.indid, i.name
	, c.name 
from sysindexes i
join sysobjects o
	on i.id = o.id
join @indexes tmp
	on i.[name]	= tmp.IndexName
join sys.index_columns ic
	on i.indid =ic .index_id	
	and i.id = ic.object_id
	and ic.is_included_column = 1
join sys.columns c
	on ic.column_id = c.column_id
	and ic.object_id = c.object_id
where o.type = 'u'
and o.[name] = 'scReturnsAudit'


SELECT      o.name as [Object], k.name as [Index/Constraint], i.name as [ForeignIndex/Constraint]
			, i.indid
			, idx.IndexKeys
			,
            STUFF((    SELECT ',' + ic.ColName
                        FROM @includedColumns ic
                        WHERE
                        ic.IndexName = idx.IndexName
                        FOR XML PATH('')
                        ), 1, 1, '' )
            AS [IncludedColumns]
FROM sys.foreign_keys k
join sys.sysindexes i
	on k.referenced_object_id = i.id
	and k.key_index_id = i.indid
join sysobjects o
	on k.parent_object_id = o.id
full outer join @indexes idx
	on i.[name]	= idx.IndexName
WHERE [parent_object_id] = OBJECT_ID( @objectName )
union
select o.[name], i.[name], null
	, i.indid
	, idx.IndexKeys
	,
            STUFF((    SELECT ',' + ic.ColName
                        FROM @includedColumns ic
                        WHERE
                        ic.IndexName = idx.IndexName
                        FOR XML PATH('')
                        ), 1, 1, '' )
            AS [IncludedColumns]
from sysindexes i
join sysobjects o
	on i.id = o.id
join @indexes idx
	on i.[name]	= idx.IndexName
where o.type = 'u'
and o.[name] = @objectname
order by 4