IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[support_TableInfo]') AND type in (N'P'))
DROP PROCEDURE [dbo].[support_TableInfo]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[support_TableInfo] (
	  @objectName nvarchar(20)
)	
AS
/************************************************************************

	$History: $

*************************************************************************/
BEGIN



	--declare @objectName	varchar(256)
	declare @obj varchar(256)

	create table #keys (
		  IndexName nvarchar(256)
		, IndexDescription nvarchar(1024)
		, IndexKeys nvarchar(2048)
	)

	insert into #keys
	exec sp_helpindex @objectName
		
	declare obj_cursor cursor
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

	open obj_cursor
	fetch next from obj_cursor into @obj
	while @@fetch_status = 0
	begin
		--print @objectName
		insert into #keys
		exec sp_helpindex @obj

		fetch next from obj_cursor into @obj
	end

	SELECT o.name as [Table], k.name as [ForeignKey], i.name as [IndexName]
		, tmp.IndexDescription
		, tmp.IndexKeys
	FROM sys.foreign_keys k
	join sys.sysindexes i
		on k.referenced_object_id = i.id
		and k.key_index_id = i.indid
	join sysobjects o
		on k.parent_object_id = o.id
	full outer join #keys tmp
		on i.[name]	= tmp.IndexName
	WHERE [parent_object_id] = OBJECT_ID( @objectName )
	union	
	select o.[name], i.[name], null
		, tmp.IndexDescription
		, tmp.IndexKeys
	from sysindexes i
	join sysobjects o
		on i.id = o.id
	join #keys tmp
		on i.[name]	= tmp.IndexName
	where o.type = 'u'
	and o.[name] = @objectname
	--order by 2 desc

	close  obj_cursor
	deallocate obj_cursor

	drop table #keys

	RETURN
END
GO	

EXEC support_TableInfo 'scDraws'