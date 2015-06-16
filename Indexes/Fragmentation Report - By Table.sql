--To Find out fragmentation level of a given database and table
--This query will give DETAILED information
DECLARE @db_id SMALLINT;
DECLARE @object_id INT;
SET @db_id = DB_ID(N'nsdb_sample');
SET @object_id = OBJECT_ID(N'scDraws');
IF @object_id IS NULL 
BEGIN
   PRINT N'Invalid object';
END
ELSE
BEGIN
   SELECT 
		  IPS.Index_type_desc, 
		  IPS.avg_fragmentation_in_percent as [avg_fragmentation_in_percent (lower the number the better)], 
		  IPS.avg_page_space_used_in_percent as [avg_page_space_used_in_percent (higher the number the better)], 
		  IPS.record_count, 
		  IPS.ghost_record_count,
		  IPS.fragment_count as [fragment_count (less fragments the more data is stored consecutively)], 
		  IPS.avg_fragment_size_in_pages as [avg_fragment_size_in_pages (Larger fragments mean that less disk I/O is required to read the same number of pages)]
   FROM sys.dm_db_index_physical_stats(@db_id, @object_id, NULL, NULL , 'DETAILED') AS IPS;
END
GO