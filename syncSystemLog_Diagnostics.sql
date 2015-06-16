IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[syncIndexMaintenance_Diagnostic]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[syncIndexMaintenance_Diagnostic]
GO

CREATE PROCEDURE dbo.syncIndexMaintenance_Diagnostic
	  @db_name nvarchar(50)
	, @fillfactor int = 100
	, @fragThreshold_REORG_LowerLimit nvarchar(10) = 10
	, @fragThreshold_REBUILD_LowerLimit nvarchar(10) = 30
AS
/*

*/

	set nocount on

	declare @msg nvarchar(1000) 
	declare @db_id smallint

	declare @objectId int;
	declare @indexId int;
	declare @partitionCount bigint;
	declare @schemaName nvarchar(130); 
	declare @ojbectName nvarchar(130); 
	declare @indexName nvarchar(130); 
	declare @partitionNum bigint;
	declare @partitions bigint;
	declare @frag float;
	declare @command nvarchar(4000); 

	/*
		We need a valid database, a null db_id would retrieve stats for all databases
	*/	
	set @db_id = db_id(@db_name)
	if @db_id is null
	begin
		set @msg = 'Database ''' + @db_name + ''' does not exist.'
		raiserror(@msg, 11, 1)
	end

	/*
		Make sure we are in the database that was passed in the db parameter, otherwise
		we could retrieve stats from one database and execute them in a different databaswe
	*/
	if @db_name <> db_name()
	begin
		set @msg = 'Database ''' + @db_name + ''' does not correspond with the current database ''' + db_name() + '''.  To proceed, please execute:  USE ' + @db_name 
		raiserror(@msg, 11, 1)	
	end
	
	if @fragThreshold_REORG_LowerLimit >= @fragThreshold_REBUILD_LowerLimit
	begin
		set @msg = 'Parameter @fragThreshold_REORG_LowerLimit (' + cast(@fragThreshold_REORG_LowerLimit as varchar)
		 + ') must be smaller than @fragThreshold_REBUILD_LowerLimit (' + cast(@fragThreshold_REBUILD_LowerLimit as varchar) + ')'
		 raiserror(@msg, 11, 1)	
	end
	
	--|  Log procedure starting...
	--set @msg = 'syncIndexMaintenance_Diagnostic:  Procedure starting...'
	--exec syncSystemLog_Insert @ModuleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg, @Source='IndexMaint'
	--print @msg

	/*
		Create a table to hold index statistics
	*/
	if exists (
		select *
		from sysobjects
		where id = object_id('fragmentedTables')
	)
	begin	
		delete dbo.fragmentedTables
	end
	else
	begin
		print 'creating table dbo.fragmentedTables...'
		create table dbo.fragmentedTables (
			  TableId int
			, TableName nvarchar(256)
			, IndexId int
			, IndexName nvarchar(256)
			, IndexType nvarchar(120)
			, SchemaName nvarchar(50)
			, PartitionNum int
			, AvgFragmentationPercent float
			, AvgFragmentationPercent_After float
		)
	end
		
	/*
		Retrieve index statistics
	*/
	insert into fragmentedTables (
		TableId
		, TableName
		, IndexId
		, IndexName
		, IndexType
		, SchemaName
		, PartitionNum
		, AvgFragmentationPercent
		, AvgFragmentationPercent_After
	)
	select 
		  ips.object_id					as TableId
		, object_name( ips.object_id )	as TableName
		, si.index_id					as IndexId
		, si.name						as IndexName
		, si.type_desc					as IndexType
		, schema_name( st.schema_id )	as SchemaName
		, partition_number				as PartitionNum
		, avg_fragmentation_in_percent	as AvgFragmentationPercent
		, 0.0							as AvgFragmentationPercent_After
	from sys.dm_db_index_physical_stats(@db_id, NULL, NULL, NULL , 'LIMITED') ips 
	join sys.tables st with (nolock) 
		on ips.object_id = st.object_id 
	join sys.indexes si with (nolock) 
		on ips.object_id = si.object_id
		and ips.index_id = si.index_id 
	where st.is_ms_shipped = 0 
	and si.name IS NOT NULL 
	and avg_fragmentation_in_percent >= CONVERT(DECIMAL, @fragThreshold_REORG_LowerLimit) 
	and si.index_id > 0 
	and page_count > 100
	order by avg_fragmentation_in_percent DESC 	
		
	--set @msg = 'syncIndexMaintenance_Diagnostic:  Found ' + cast(@@rowcount as varchar) + ' objects to reorg/rebuild'
	--exec syncSystemLog_Insert @ModuleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg, @Source='IndexMaint'
	--print @msg
	
	insert into syncSystemLog ( 
		  LogMessage
		, SLTimeStamp
		, ModuleId
		, SeverityId
		, CompanyId
		, [Source]
		--, GroupId 
	)
	select distinct 
	 coalesce ( case 
		when ( AvgFragmentationPercent >= @fragThreshold_REORG_LowerLimit) and (AvgFragmentationPercent < @fragThreshold_REBUILD_LowerLimit)
			then '[diagnostic] AvgFragmentationPercent on ''' + TableName + '''/''' + IndexName + ''': ' + cast(AvgFragmentationPercent as varchar) + '.  REORG'
		when ( AvgFragmentationPercent >= @fragThreshold_REBUILD_LowerLimit)
			then '[diagnostic] AvgFragmentationPercent on ''' + TableName + '''/''' + IndexName + ''': ' + cast(AvgFragmentationPercent as varchar) + '.  REBUILD'	
		else '[diagnostic] AvgFragmentationPercent on ''' + TableName + '''/''' + IndexName + ''': ' + cast(AvgFragmentationPercent as varchar)
		end , 'No objects to REORG/REBUILD' ) as [LogMessage]
		, getdate() as [SLTimeStamp]
		, 2 as [ModuleId]	--|2=SingleCopy
		, 0 as [SeverityId] --|0=Information, 1=Warning
		, 1 as [CompanyId]
		, N'IndexMaint' as [Source]   --|nvarchar(100)
	from fragmentedTables

	
	--|  Log procedure complete
	--set @msg = 'syncIndexMaintenance_Diagnostic:  Procedure completed successfully.'
	--exec syncSystemLog_Insert @ModuleId=2, @SeverityId=0, @CompanyId=1, @Message=@msg, @Source='IndexMaint'
	--print @msg

GO

