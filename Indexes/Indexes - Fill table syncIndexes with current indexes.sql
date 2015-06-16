begin tran
	set nocount on

	if not exists (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[syncIndexes]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
	begin
		create table [dbo].[syncIndexes](
			  ObjectName nvarchar(256)
			, IndexName nvarchar(256)
			, IndexDescription nvarchar(1024)
			, IndexKeys nvarchar(2048)
		)
	end
	else
	begin
		delete from [dbo].[syncIndexes]
	end

	create table #indexes (
		  IndexName nvarchar(256)
		, IndexDescription nvarchar(1024)
		, IndexKeys nvarchar(2048)
	)

	declare @objectName	varchar(256)

	declare object_cursor cursor 
	for 
		select [Name] 
		from dbo.sysobjects 
		where type='U'
		for read only
	
	open object_cursor 
	fetch next from object_cursor into @objectName
	while @@fetch_status = 0
	begin

		insert into #indexes
		exec sp_helpindex @objectName

		insert into syncIndexes ( ObjectName, IndexName, IndexDescription, IndexKeys )
		select @objectName, IndexName, IndexDescription, IndexKeys 
		from #indexes

		delete from #indexes
		
		fetch next from object_cursor into @objectName
	end

	close object_cursor
	deallocate object_cursor

	drop table #indexes

	select ObjectName, IndexName, replace(IndexDescription, ',', ';') as [IndexDescription], replace(IndexKeys, ',', ';') as [IndexKeys]
	from syncIndexes
	order by ObjectName, IndexName

rollback tran
