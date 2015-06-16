set nocount on

declare @defaultBackupPath nvarchar(256)	--|  This is the root path of the default backup path
declare @db_catalog nvarchar(50)
declare @file_count int 
declare @counter int
declare @sql nvarchar(max)
declare @cmd varchar(500)
declare @version nvarchar(20)

set @counter = 1
set @file_count = 4

--|  Get the default backup path for SQL Server from the Registry
EXECUTE @defaultBackupPath = master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
	, N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer'
	, N'BackupDirectory'
	, @param = @defaultBackupPath OUTPUT


/*

*/	

declare company_cursor cursor
for
	select CoDbCatalog
	from NSSESSION..nsSessionCompanies
	where CoActive = 1
	and CoDbCatalog in ( 
		  'nsdb_dal'
	)
	
open company_cursor
fetch next from company_cursor into @db_catalog
while @@fetch_status = 0
begin
	--| set the file count based on db size
	SELECT @file_count = 
		case when size*8/1000000 > 0 then size*8/1000000
		else 1 end
	FROM sys.master_files	
	WHERE DB_NAME(database_id) = @db_catalog
	and physical_name like '%' + @db_catalog + '.mdf'
	print 'file count: ' + cast(@file_count as varchar)

	set @sql = 'BACKUP DATABASE ' + @db_catalog + ' TO
	'

	while @counter <= @file_count
	begin
		set @sql = @sql + '	DISK = ''' + @defaultBackupPath + '\' + @db_catalog + '_' + cast(@counter as varchar) + '.bak''
		'
		if @counter + 1 <= @file_count
		begin
			set @sql = @sql + ', '
		end
		
		set @counter = @counter + 1
	end
	set @sql = @sql + ' WITH INIT
	'
	print @sql
	exec(@sql)

	--reset counter
	set @counter = 1

	while @counter <= @file_count
	begin
		set @cmd = 'C:\Progra~1\7-Zip\7z.exe e "' + @defaultBackupPath + '\' + @db_catalog + '_' + cast(@counter as varchar) +  '.zip" -y'
		print @cmd
		exec xp_cmdshell @cmd

		set @counter = @counter + 1
	end
	print ''
	
	--reset counter
	set @counter = 1
	set @sql = 'RESTORE DATABASE ' + @db_catalog + ' FROM
	'

	while @counter <= @file_count
	begin
		set @sql = @sql + '	DISK = ''' + @defaultBackupPath + '\' + @db_catalog + '_' + cast(@counter as varchar) + '.bak''
		'
		if @counter + 1 <= @file_count
		begin
			set @sql = @sql + ', '
		end
		
		set @counter = @counter + 1
	end
	set @sql = @sql + ' WITH FILE = 1
	, REPLACE
	'
	print @sql
	--exec(@sql)
	
	--reset counter
	set @counter = 1

	while @counter <= @file_count
	begin
		set @cmd = 'C:\Progra~1\7-Zip\7z.exe a "' + @defaultBackupPath + '\' + @db_catalog + '_' + cast(@counter as varchar) +  '.zip" "' + @defaultBackupPath + '\' + @db_catalog  + '_' + cast(@counter as varchar) + '.bak" -mx3'
		print @cmd
		exec xp_cmdshell @cmd
		
		set @cmd = 'DEL "' + @defaultBackupPath + '\' + @db_catalog + '_' + cast(@counter as varchar) +  '.bak"'
		exec xp_cmdshell @cmd
		set @counter = @counter + 1
	end
	
	--reset counter
	set @counter = 1
	
	fetch next from company_cursor into @db_catalog
end		

close company_cursor
deallocate company_cursor	
