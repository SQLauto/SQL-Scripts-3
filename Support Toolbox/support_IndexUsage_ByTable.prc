IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_IndexUsageByTable]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[support_IndexUsageByTable]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_IndexUsageByTable]
	  @objectname nvarchar(256)
AS
/*
	[dbo].[support_IndexUsageByTable]
	
	$History:  $
*/
BEGIN
	declare @includedColumns table ( [ObjId] int, IndexId int, IndexName nvarchar(256), ColName nvarchar(256) )
	declare @indexes table ( IndexName nvarchar(256), IndexDescription nvarchar(1024), IndexKeys nvarchar(2048) )

	--declare @objectName	varchar(256)
	declare @obj varchar(256)

	--set @objectname = 'scReturnsAudit'

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

	;with cteIndexes as (
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
		--order by 4	
	)
	, cteUsage as (
	select    
		o.name
		, i.indid
		, usg.user_seeks, usg.user_scans, usg.user_lookups
		, usg.user_updates
		, usg.last_user_seek, usg.last_user_scan, usg.last_user_lookup
	from sysindexes i
	join sysobjects o
		on i.id = o.id
	join SYS.DM_DB_INDEX_USAGE_STATS usg 
		on o.id = usg.object_id
		and i.indid= usg.index_id
	join @indexes idx
		on i.[name]	= idx.IndexName
		where o.type = 'u'
		and o.[name] = @objectname
	)
	
	select ind.*
		, usg.*
	from cteIndexes ind
	join cteUsage usg
		on ind.Object = usg.name
		and ind.indid = usg.indid
	
END
GO	