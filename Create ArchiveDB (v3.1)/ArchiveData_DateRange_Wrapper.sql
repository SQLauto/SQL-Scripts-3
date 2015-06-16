set nocount on
/*
	SingleCopy v3.1.3

	This procedure is designed to create an arhive database(s) from an existing 
	production database.  

	This procedure assumes that the archive databases will span a single calendar year 
	and that you will retain a single year's worth of data.  For example, if you have data
	dating back to January 2007 and it is December 2009 and you run this procedure, you will 
	end up with the following:

	before:
		prodcution_database - containing data 1/1/2007 to 12/31/2009
	after:
		production_database - containing data 1/1/2009 to 12/31/2009
		archive_database_2008 - containing data 1/1/2008 to 12/31/2008
		archive_database_2007 - containing data 1/1/2007 to 12/31/2007

	Overview
	--------
	1)  Set the "source" database variable.  This is the database you wish to archive data out of
	2)  Install the procedures scArchiveData and scDeleteData in the source database
	3)	Run this scArchiveDataWrapper procedure. The procedure does the following:
		a)  Backups up the source database
		b)  Determines the oldest year that exists in the source database.  This will be the first year
			that is archived.
		c)  Restores the backup using a new name (e.g.  nsdb_archive_2007
		d)  Removes all historic data not within the archive year
		e)  Shrinks the newly created archive database
		e)	Deletes from the source database the data that was just archived
		f)  Shrinks the source database
		g)  Repeats if there are additional years that can be archived.

*/


--|	 Declarations 
declare @sourcedb_name nvarchar(256) 
declare @retentionPeriod_Months int

--|	 Declarations cont.
declare @archive_min datetime	--|  automatically determined based on year that is being archived.  Passed to the archive/delete stored procedures
declare @archive_max datetime	--|  automatically determined based on year that is being archived.  Passed to the archive/delete stored procedures
declare @targetdb_name nvarchar(256) --|  This is derived from the source database name and the year that is being archived.
declare @defaultBackupPath nvarchar(256)	--|  This is the root path of the default backup path
declare @sourcedb_filename_full nvarchar(256)  --|  This is the backup path concatenated with the target database name
declare @archive_year int	--|  used to determine the year to be archived
declare @sql nvarchar(4000)
declare @dbsize nvarchar(25)
DECLARE @LogicalNameData nvarchar(128), @LogicalNameLog nvarchar(128)

---------------------------------------------------------------------------------------------
--	MODIFY THE FOLLOWING VARIABLES AS NECESSARY
---------------------------------------------------------------------------------------------
set @sourcedb_name = 'nsdb_mil'  --|  This is the database you want to archive data out of
set @retentionPeriod_Months = 13
---------------------------------------------------------------------------------------------



--|  Validate prerequities
if @sourcedb_name <> db_name()
begin
	print 'The current database must match the @sourcedb_name parameter.  Please run this procedure in the ''' + @sourcedb_name + ''' database.'
	return	
end

if not exists (
	select *
	from sysobjects 
	where id = object_id('scArchiveData')
	and type = 'P'
)
begin
	print 'This procedure depends on the stored procedure ''scArchiveData'' which does not exist in this database.  Please install stored procedure ''scArchiveData''.'
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


--|  Get the default backup path for SQL Server from the Registry
EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
	, N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer'
	, N'BackupDirectory'
	, @param = @defaultBackupPath OUTPUT

--|  
	set @sourcedb_filename_full = case 
			when right(@defaultBackupPath,1) = '\' then @defaultBackupPath
			else @defaultBackupPath + '\'
			end
			 + '' + @sourcedb_name + '_archive_source'

print 'Backing up source database to ''' + @sourcedb_filename_full + '''...'

	/*
		Create a backup file that will be later restored as an "archive" database.  This backup
		can be used as the source for all archive years
	*/
	set @sql = 'backup database ' + @sourcedb_name + ' to disk = ''' + @sourcedb_filename_full + ''' with init'
	--print @sql
	exec(@sql)




/*
	Archive the data & delete from the source database
*/
	--|Single Archive 
	select @archive_min = cast('1/1/' + cast( datepart(yy, min(drawdate)) as varchar) as datetime)
	from scDraws
	
	set @archive_max = cast( cast( dateadd( MONTH, -1*@retentionPeriod_Months, GETDATE() ) as varchar) as datetime)
	
		
	set @targetdb_name = @sourcedb_name + '_archive_' + replace( convert( varchar, @archive_min, 101), '/', '' )
						 + '_' + replace( convert( varchar, @archive_max, 101), '/', '' )
	
	

	print '@targetdb_name = ' + @targetdb_name
	print ''
	print 'Archiving data between ''' + convert(varchar, @archive_min, 101) + ''' and ''' + convert( varchar, @archive_max, 101) + '''.'

	/*
		Restore the database as an archive database
	*/
	CREATE TABLE tmpRestore (
		LogicalName nvarchar(128)
		, PhysicalName nvarchar(260)
		, [Type] char(1)
		, FileGroupName nvarchar(128)
		, [Size] numeric(20, 0)
		, [MaxSize] numeric(20, 0)
		, [FileId] bigint
		, CreateLSN numeric(25,0)
		, DropLSN numeric(25,0)
		, UniqueID uniqueidentifier
		, ReadOnlyLSN numeric(25,0) 
		, ReadWriteLSN numeric(25,0)
		, BackupSizeInBytes bigint
		, SourceBlockSize int
		, FileGroupID int
		, LogGroupGUID uniqueidentifier
		, DifferentialBaseLSN numeric(25,0)
		, DifferentialBaseGUID uniqueidentifier
		, IsReadOnly bit
		, IsPresent bit
		, TDEThumbprint varbinary(32)
		)

	INSERT INTO tmpRestore
	EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @sourcedb_filename_full + '''')

	--DECLARE @LogicalNameData nvarchar(128), @LogicalNameLog nvarchar(128)

	SELECT @LogicalNameData = LogicalName
	FROM tmpRestore
	WHERE Type = 'D'

	SELECT @LogicalNameLog = LogicalName
	FROM tmpRestore
	WHERE Type = 'L'

	DROP TABLE tmpRestore
	print ''
	print 'Restoring backup to ''' + @targetdb_name + '''...'

		set @sql = 'RESTORE DATABASE ' + @targetdb_name + ' from disk = ''' + @sourcedb_filename_full + ''''
			+ ' with move ''' + @LogicalNameData + ''' to ''C:\Program Files\Microsoft SQL Server\MSSQL\Data\' + @targetdb_name + '_Data.mdf'''
			+ ', move ''' + @LogicalNameLog + ''' to ''C:\Program Files\Microsoft SQL Server\MSSQL\Data\' + @targetdb_name + '_log.ldf'''
		--print @sql
		exec(@sql)

		set @sql = 'ALTER DATABASE ' + @targetdb_name + ' MODIFY FILE ( NAME=' + @LogicalNameData + ', NEWNAME=' + @targetdb_name + ')'
		print @sql
		exec(@sql)
		set @sql = 'ALTER DATABASE ' + @targetdb_name + ' MODIFY FILE ( NAME=' + @LogicalNameLog + ', NEWNAME=' + @targetdb_name + '_log)'
		print @sql
		exec(@sql)
	print 'Database restore complete.'
		/*
			Remove all data except for the archive year
		*/
	print 'Cleaning up archive database...'
		set @sql = 'use ' + @targetdb_name + ' exec scArchiveData @archive_min=''' + convert( varchar, @archive_min, 101) + ''', @archive_max=''' + convert( varchar, @archive_max, 101) + ''''
		print @sql
		exec(@sql)
	print 'Cleanup complete.'
		/*
			Delete the archive year from the source database
		*/
	print 'Deleting archived data from source database...'
		set @sql = 'use ' + @sourcedb_name + ' exec scDeleteData @archive_min=''' + convert( varchar, @archive_min, 101) + ''', @archive_max=''' + convert( varchar, @archive_max, 101) + ''''
		print @sql
		exec(@sql)

	--|  Shrink
	set @sql = 'DBCC SHRINKFILE(''' +  @LogicalNameData + ''', 0 )'
	print @sql
	exec(@sql)
	set @sql = 'DBCC SHRINKFILE(''' +  @LogicalNameLog + ''', 0 )'
	print @sql
	exec(@sql)

	  ---------------------------
	--|	Database Statistics		|--
	  ---------------------------
	if not exists(
		select *
		from sysobjects
		where id = object_id('helpdb')
	)
	begin
		CREATE TABLE helpdb (
			[name] nvarchar(100)
			,[dbsize] nvarchar(25)
			,[owner] nvarchar(25)
			,[dbid] int
			,[created] datetime
			,[status] nvarchar(256)
			,[compatiblity_level] int
		   )
	end
	else
	begin
		truncate table helpdb
	end

	INSERT INTO helpdb
	EXEC sp_helpdb

	select @dbsize = [dbsize]
	from helpdb
	where [name] = @sourcedb_name
	
	print 'Size of database ''' + @sourcedb_name + ''' is ' + @dbsize
	
	drop table helpdb
		print 'Archived data deleted from source database.'
		print ''
		print ''

	set @archive_year = @archive_year + 1
