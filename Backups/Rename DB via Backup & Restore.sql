set nocount on
/*
	
*/


--|	 Declarations 
declare @sourcedb_name nvarchar(256) 
declare @targetdb_name nvarchar(256)

---------------------------------------------------------------------------------------------
--	MODIFY THE FOLLOWING VARIABLES AS NECESSARY
---------------------------------------------------------------------------------------------
set @sourcedb_name = 'SDMConfig_TORO'  --|  This is the database you want to archive data out of
set @targetdb_name = 'SDMConfig'

---------------------------------------------------------------------------------------------

--|	 Declarations cont.
declare @defaultBackupPath nvarchar(256)	--|  This is the root path of the default backup path
declare @defaultDataPath nvarchar(256)
declare @sourcedb_filename_full nvarchar(256)  --|  This is the backup path concatenated with the target database name
declare @sql nvarchar(4000)
declare @dbsize nvarchar(25)


--|  Validate prerequities
if @sourcedb_name <> db_name()
begin
	print 'The current database must match the @sourcedb_name parameter.  Please run this procedure in the ''' + @sourcedb_name + ''' database.'
	return	
end

--|  Get the default backup path for SQL Server from the Registry
EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
	, N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer'
	, N'BackupDirectory'
	, @param = @defaultBackupPath OUTPUT

EXECUTE master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
	, N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer'
	, N'DefaultData'
	, @param = @defaultDataPath OUTPUT

--|  
	set @sourcedb_filename_full = case 
			when right(@defaultBackupPath,1) = '\' then @defaultBackupPath
			else @defaultBackupPath + '\'
			end
			 + @sourcedb_name + '.bak'

print 'Backing up source database to ''' + @sourcedb_filename_full + '''...'

set @sql = 'backup database ' + @sourcedb_name + ' to disk = ''' + @sourcedb_filename_full + ''' with init'
print @sql
exec(@sql)

	
	
CREATE TABLE ##Restore (
    LogicalName          nvarchar(128),
    PhysicalName         nvarchar(260),
    [Type]               char(1),
    FileGroupName        nvarchar(128),
    Size                 numeric(20,0),
    MaxSize              numeric(20,0),
    FileID               bigint,
    CreateLSN            numeric(25,0),
    DropLSN              numeric(25,0),
    UniqueID             uniqueidentifier,
    ReadOnlyLSN          numeric(25,0),
    ReadWriteLSN         numeric(25,0),
    BackupSizeInBytes    bigint,
    SourceBlockSize      int,
    FileGroupID          int,
    LogGroupGUID         uniqueidentifier,
    DifferentialBaseLSN  numeric(25,0),
    DifferentialBaseGUID uniqueidentifier,
    IsReadOnl            bit,
    IsPresent            bit,
    TDEThumbprint        varbinary(32) -- remove this column if using SQL 2005
)

	INSERT INTO ##Restore
	EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @sourcedb_filename_full + '''')

	DECLARE @LogicalNameData nvarchar(128), @LogicalNameLog nvarchar(128)

	SELECT @LogicalNameData = LogicalName
	FROM ##Restore
	WHERE Type = 'D'

	SELECT @LogicalNameLog = LogicalName
	FROM ##Restore
	WHERE Type = 'L'



	DROP TABLE ##Restore

	print ''
	print 'Restoring backup to ''' + @targetdb_name + '''...'

	set @sql = 'RESTORE DATABASE ' + @targetdb_name + ' from disk = ''' + @sourcedb_filename_full + ''''
		+ ' with move ''' + @LogicalNameData + ''' to ''' + @defaultDataPath + '\' + @targetdb_name + '.mdf'''
		+ ', move ''' + @LogicalNameLog + ''' to ''' + @defaultDataPath + '\' + @targetdb_name + '_log.ldf'''
	print @sql
	exec(@sql)

	set @sql = 'ALTER DATABASE ' + @targetdb_name + ' MODIFY FILE ( NAME=' + @LogicalNameData + ', NEWNAME=' + @targetdb_name + ')'
	print @sql
	exec(@sql)
		
	set @sql = 'ALTER DATABASE ' + @targetdb_name + ' MODIFY FILE ( NAME=' + @LogicalNameLog + ', NEWNAME=' + @targetdb_name + '_log)'
	print @sql
	exec(@sql)
	print 'Database restore complete.'
		

