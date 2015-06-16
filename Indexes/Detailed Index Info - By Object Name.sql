declare @db_id smallint;
declare @objectName	varchar(256)

set @db_id = db_id( 'nsdb_sample' );
set @objectName = N'scDraws'


create table #indexes (
	  IndexName nvarchar(256)
	, IndexDescription nvarchar(1024)
	, IndexKeys nvarchar(2048)
)

insert into #indexes
exec sp_helpindex @objectName

select st.name as [TableName]
	, isnull(si.name, '') as [IndexName]
	, si.type_desc as [IndexType]
	, i.IndexKeys
	, ips.index_depth
	, ips.index_level
	, ips.record_count
	--, ips.ghost_record_count
	, ssi.rowcnt 
	, ips.fragment_count
	, ips.avg_fragmentation_in_percent 
	, ips.avg_fragment_size_in_pages
	, ips.avg_page_space_used_in_percent
	, ips.avg_fragment_size_in_pages
	--, ssi.rowmodctr
	, user_updates = isnull(ius.user_updates, 0)
	, user_seeks = isnull(ius.user_seeks, 0) 
	, user_scans = isnull(ius.user_scans, 0) 
	, user_lookups = isnull(ius.user_lookups, 0)
from sys.dm_db_index_usage_stats ius 
right join sys.indexes si 
	on  ius.[object_id] = si.[object_id] 
	and ius.index_id = si.index_id
right join  sys.dm_db_index_physical_stats( @db_id, object_id( @objectName ), NULL, NULL , 'DETAILED' ) as ips
	on ius.object_id = ips.object_id
	and ius.index_id = ips.index_id									
join sys.sysindexes ssi 
	on si.object_id = ssi.id 
	and si.name = ssi.name
join sys.tables st 
	on st.[object_id] = si.[object_id]
join sys.schemas ss 
	on ss.[schema_id] = st.[schema_id]
join #indexes i
	on i.IndexName = si.name
where ius.database_id = @db_id
and  objectproperty( ius.[object_id], 'IsMsShipped' ) = 0
and si.object_id = object_id( @objectName )


drop table #indexes