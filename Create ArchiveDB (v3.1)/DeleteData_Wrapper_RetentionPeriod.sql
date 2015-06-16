set nocount on
/*
	SingleCopy v3.1.3

	This procedure is designed to delete data from an existing 
	production database.  

	Overview
	--------
	1)  Set the "source" database variable.  This is the database you wish to archive data out of
	2)  Install the procedure scDeleteData in the source database
	3)	Run the DeleteData_Wrapper_RetentionPeriod procedure. The procedure does the following:
		a)	Deletes from the source database
*/


--|	 Declarations 
declare @sourcedb_name nvarchar(256) 
declare @retentionPeriod_Months int

---------------------------------------------------------------------------------------------
--	MODIFY THE FOLLOWING VARIABLES AS NECESSARY
---------------------------------------------------------------------------------------------
set @sourcedb_name = 'nsdb_chi'  --|  This is the database you want to archive data out of
set @retentionPeriod_Months = 1
---------------------------------------------------------------------------------------------


--|	 Declarations cont.
declare @archive_min datetime	--|  automatically determined based on year that is being archived.  Passed to the archive/delete stored procedures
declare @archive_max datetime	--|  automatically determined based on year that is being archived.  Passed to the archive/delete stored procedures
declare @targetdb_name nvarchar(256) --|  This is derived from the source database name and the year that is being archived.
declare @defaultBackupPath nvarchar(256)	--|  This is the root path of the default backup path.
											--|  Path is used to create the "source" backup.
declare @sourcedb_filename_full nvarchar(256)	--|  Fully Qualified Path to SourceDB.  

declare @sql nvarchar(4000)
declare @dbsize nvarchar(25)
declare @LogicalNameData nvarchar(128)	--|  Needed to "rename" restored db.  e.g.  Logical Name = nsdb27_dat
declare @LogicalNameLog nvarchar(128)	--|  Needed to "rename" restored db.  e.g.  Logical Name = nsdb27_log



--|  Validate prerequities
if @sourcedb_name <> db_name()
begin
	print 'The current database must match the @sourcedb_name parameter.  Please run this procedure in the ''' + @sourcedb_name + ''' database.'
	return	
end

if not exists (
	select *
	from sysobjects 
	where id = object_id('scDeleteData')
	and type = 'P'
)
begin
	print 'This procedure depends on the stored procedure ''scDeleteData'' which does not exist in this database.  Please install stored procedure ''scDeleteData''.'
	return
end

/*
	Start the delete process:
*/

	print 'Initialize delete processes...'
	
	--|  Determine the archive min date
	select @archive_min = cast('1/1/' + cast( datepart(yy, min(drawdate)) as varchar) as datetime)
	from scDraws
	
	--|  Use the retention period to determine the archive max date
	set @archive_max = cast( cast( dateadd( MONTH, -1*@retentionPeriod_Months, GETDATE() ) as varchar) as datetime)
	
	print '  Deleting data between ''' + convert(varchar, @archive_min, 101) + ''' and ''' + convert( varchar, @archive_max, 101) + '''.'
	print ''
	
	/*
		Delete data from Source database
	*/
	print '  Deleting archived data from source database...'
		set @sql = 'use ' + @sourcedb_name + ' exec scDeleteData @archive_min=''' + convert( varchar, @archive_min, 101) + ''', @archive_max=''' + convert( varchar, @archive_max, 101) + ''''
		print @sql
		exec(@sql)
	print '  Data successfully removed from source database.'

	/*
		Shrink 
	*/
	print '  Shrinking source database...'
		
	set @sql = 'DBCC SHRINKFILE(''' +  @sourcedb_name + ''', 0 )'
	print @sql
	exec(@sql)
	set @sql = 'DBCC SHRINKFILE(''' +  @sourcedb_name + '_log' + ''', 0 )'
	print @sql
	exec(@sql)
	
	print '  Shrink completed.'

print 'Process Completed'

