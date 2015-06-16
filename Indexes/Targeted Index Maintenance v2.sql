/*

*/
declare @db_name nvarchar(50)

declare @cmd NVARCHAR(1000)  
declare @Table VARCHAR(255)  
declare @SchemaName VARCHAR(255) 
declare @IndexName VARCHAR(255) 
declare @AvgFragmentationInPercent DECIMAL 
declare @fillfactor INT  
declare @fragThreshold_Reorg_LowerLimit VARCHAR(10) 
declare @fragThreshold_Rebuild_LowerLimit VARCHAR(10) 
declare @Message VARCHAR(1000) 


declare @db_id SMALLINT;
declare @object_id INT;

set nocount on 

set @db_name = 'nsdb_mil'
set @fillfactor = 100  
set @fragThreshold_Reorg_LowerLimit = '10.0' -- Percent 
set @fragThreshold_Rebuild_LowerLimit = '30.0' -- Percent 

begin try 
	set @db_id = db_id(@db_name)
	if @db_id is null
	begin
		set @Message = 'Database ''' + @db_name + ''' does not exist.'
		--print @Message
		raiserror(@Message, 11, 1)
	end
	
	if @db_name <> db_name()
	begin
		set @Message = 'Database ''' + @db_name + ''' does not correspond with the current database ''' + db_name() + '''.  To proceed, please execute:  USE ' + @db_name 
		--print @Message
		raiserror(@Message, 11, 1)	
	end
		
	if exists (
		select *
		from sysobjects
		where id = object_id('fragmentedTables_Prelim')
	)
	begin	
		drop table fragmentedTables_Prelim
	end
	
	create table fragmentedTables_Prelim (
		  TableId int
		, TableName nvarchar(256)
		, IndexId int
		, IndexName nvarchar(256)
		, IndexType nvarchar(120)
		, SchemaName nvarchar(50)
		, AvgFragmentationPercent float
		, AvgFragmentationPercent_After float
		, [Action] nvarchar(1048)
		, IsProcessed int
	)


	insert into fragmentedTables_Prelim (
		TableId
		, TableName
		, IndexId
		, IndexName
		, IndexType
		, SchemaName
		, AvgFragmentationPercent
		, AvgFragmentationPercent_After
		, [Action]
		, IsProcessed 
	)
	select 
		  ips.object_id					as TableId
		, object_name( ips.object_id )	as TableName
		, si.index_id					as IndexId
		, si.name						as IndexName
		, si.type_desc					as IndexType
		, schema_name( st.schema_id )	as SchemaName
		, avg_fragmentation_in_percent	as AvgFragmentationPercent
		, 0.0							as AvgFragmentationPercent_After
		, null							as [Action]
		, 0								as IsProcessed 
	from sys.dm_db_index_physical_stats(@db_id, NULL, NULL, NULL , NULL) ips 
	join sys.tables st with (nolock) 
		on ips.object_id = st.object_id 
	join sys.indexes si with (nolock) 
		on ips.object_id = si.object_id
		and ips.index_id = si.index_id 
	where st.is_ms_shipped = 0 and si.name IS NOT NULL 
	and avg_fragmentation_in_percent >= CONVERT(DECIMAL, @fragThreshold_Reorg_LowerLimit) 
	order by avg_fragmentation_in_percent DESC 

--select *
--from fragmentedTables_prelim
--order by TableName

--select distinct Case
update fragmentedTables_Prelim
set [Action] = 
	case 
		when ClusteredIndex = 1 and indexType = 'CLUSTERED' then --'Rebuild'
			case 
				when (AvgFragmentationPercent >= @fragThreshold_Reorg_LowerLimit) and (AvgFragmentationPercent < @fragThreshold_Rebuild_LowerLimit)
					then 
						'ALTER INDEX ' + IndexName + ' on [' + RTRIM(LTRIM(SchemaName)) + '].[' + RTRIM(LTRIM(pre.TableName)) + '] REORGANIZE' 
				when ( AvgFragmentationPercent >= @fragThreshold_Rebuild_LowerLimit ) 
					then 
						'ALTER INDEX ' + IndexName + ' on [' + RTRIM(LTRIM(SchemaName)) + '].[' + RTRIM(LTRIM(pre.TableName)) + '] REBUILD with (FILLFACTOR = ' + CONVERT(VARCHAR(3),@fillfactor) + ', STATISTICS_NORECOMPUTE = OFF)' 					
				end		
		when ClusteredIndex = 1 and indexType = 'NONCLUSTERED' then null
		else 
			--| No Clustered Index in need of reindex, so just reorganize the table which will take care of all the non-clustered indexes
			'ALTER INDEX ALL  on [' + RTRIM(LTRIM(SchemaName)) + '].[' + RTRIM(LTRIM(pre.TableName)) + '] REORGANIZE' 
		end--  as [Action]
--		, 0 as [IsProcessed]
--into #reindexList		
from fragmentedTables_Prelim pre
left join (
	select distinct TableName, 1 as [ClusteredIndex]
	from fragmentedTables_Prelim 
	where IndexType = 'CLUSTERED'
	) as [cix]
	on pre.TableName = cix.TableName
left join (
	select distinct TableName, 1 as [NonClusteredIndex]
	from fragmentedTables_Prelim 
	where IndexType = 'NONCLUSTERED'
	) as [ncix]
	on pre.TableName = ncix.TableName

	
	WHILE EXISTS ( 
		select 1 
		--from #reindexList 
		from fragmentedTables_Prelim
		where IsProcessed = 0 
		and [Action] is not null
	) 
	BEGIN 
		select top 1 @cmd = [Action]
		--from #reindexList
		from fragmentedTables_Prelim
		where IsProcessed = 0 
		and [Action] is not null
		
		exec (@cmd)
		print @cmd

		update fragmentedTables_Prelim 
		set IsProcessed = 1  
		where [Action] = @cmd
	end 

/*

*/
	update fragmentedTables_Prelim  
	set AvgFragmentationPercent_After = ips.avg_fragmentation_in_percent
	from fragmentedTables_Prelim pre
	join sys.dm_db_index_physical_stats(@db_id, NULL, NULL, NULL , NULL) ips
		on pre.TableId =  ips.object_id
		and pre.IndexId = ips.index_id 
	join sys.tables st with (nolock) 
		on ips.object_id = st.object_id 
	join sys.indexes si with (nolock) 
		on ips.object_id = si.object_id
		and ips.index_id = si.index_id 
	where st.is_ms_shipped = 0 
	and si.name IS NOT NULL 

	select *
	from fragmentedTables_Prelim
	order by TableName

	drop table fragmentedTables_Prelim  
--	drop table #reindexList
end try

begin catch
  PRINT 'DATE : ' + CONVERT(VARCHAR, GETDATE()) + ' There is some run time exception.' 
  PRINT 'ERROR CODE : ' + CONVERT(VARCHAR, ERROR_NUMBER())  
  PRINT 'ERROR MESSAGE : ' + ERROR_MESSAGE() 
end catch
