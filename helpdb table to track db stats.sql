

--|  Create table for tracking db stats
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

	print '  Source database stats (after shrink): '
	INSERT INTO helpdb
	EXEC sp_helpdb

	select @dbsize = [dbsize]
	from helpdb
	where [name] = @sourcedb_name
	
	print '  Size of database ''' + @sourcedb_name + ''' is ' + @dbsize
