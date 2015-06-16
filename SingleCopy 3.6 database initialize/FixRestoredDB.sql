--|  use for restored backups of SingleCopy databases

declare @sqlver int
declare @obj nvarchar(255)
declare @type nvarchar(1)
declare @user nvarchar(50)
declare @sql nvarchar(2048)
declare @schema nvarchar(128)

select @sqlver =  left( cast(SERVERPROPERTY('productversion') as varchar), charindex('.', cast( SERVERPROPERTY('productversion') as varchar), 0) - 1)


if @sqlver >= 9
begin
	declare schema_cursor cursor
	for
		select [name]
		from sys.schemas s
		--where s.principal_id = user_id('nsAdmin')
		where [name] in ('nsAdmin', 'nsUser', 'nsGuest' )
		--where s.principal_id in ( 
		--	select principal_id
		--	from sys.database_principals
		--	where [name] in ('nsAdmin', 'nsUser', 'nsGuest' )
		--)		
	open schema_cursor
	fetch next from schema_cursor into @schema
	while @@fetch_status = 0
	begin
		print 'updating schemas for [' + @schema + ']...'
		set @sql = 'alter authorization on schema::[' + @schema + '] TO [dbo]'
		print @sql
		exec (@sql)

		if exists (
			select * 
			from sys.objects 
			where schema_id = schema_id(@schema)
		)	
		begin

			declare schema_obj_cursor cursor
			for
				select [name], [type]
				from sys.objects
				where schema_id = schema_id(@schema)
			
			open schema_obj_cursor
			fetch next from schema_obj_cursor into @obj, @type
			while @@FETCH_STATUS = 0
			begin
			
				--print 'Dropping objects owned by schema...'
				select @sql = case @type
					when 'P' then 
					'if exists ( 
						select 1
						from sys.objects 
						where schema_id = schema_id(''dbo'')
						and [name] = ''' + @obj + '''
						and [type] = ''' + @type + '''
						)
						begin
								drop procedure ' + @schema + '.' + @obj + '
								print ''dropping procedure ' + @schema + '.' + @obj + '...''
						end
						else
						begin
							alter schema dbo transfer ' + @schema + '.' + @obj + '
							print ''transfered ' + @schema + '.' + @obj + ' to schema [dbo]''
						end	
						' 
					when 'U' then 'if exists ( 
										select 1
										from sys.objects 
										where schema_id = schema_id(''dbo'')
										and [name] = ''' + @obj + '''
										and [type] = ''' + @type + '''
										)
										begin
												drop table ' + @schema + '.' + @obj + '
												print ''dropping table ' + @schema + '.' + @obj + '...''
										end
										else
										begin
											alter schema dbo transfer ' + @schema + '.' + @obj + '
											print ''transfered ' + @schema + '.' + @obj + ' to schema [dbo]''
										end	
										' 
						end	
				
				--set @sql = 'alter schema dbo transfer ' + @schema + '.' + @obj
				print @sql				
				exec ( @sql) 

				--print 'transfered ' + @schema + '.' + @obj + ' to schema [dbo]'
				
			fetch next from schema_obj_cursor into @obj, @type
			end
			
			close schema_obj_cursor
			deallocate schema_obj_cursor
		end
	fetch next from schema_cursor into @schema
	end

	close schema_cursor
	deallocate schema_cursor
end

if exists( select * from sys.schemas where name = 'nsAdmin')
begin
	print 'dropping schema [nsAdmin]...'
	drop schema nsAdmin
end	

if exists( select * from sys.schemas where name = 'nsUser')
begin
	print 'dropping schema [nsUser]...'
	drop schema nsUser
end

if exists( select * from sys.schemas where name = 'nsGuest')
begin
	print 'dropping schema [nsGuest]...'
	drop schema nsGuest
end

--|Add Users
	if not exists (
		select *
		from master..syslogins
		where name = 'nsAdmin'
		)
	begin
		print 'adding sql login [nsAdmin] (sp_addlogin)...'
		exec sp_addlogin 'nsAdmin', 'nsadmin'
	
		--exec sp_defaultdb 'nsAdmin', 'nsdb'
	end

	
	if not exists (
		select *
		from master..syslogins
		where name = 'nsUser'
		)
	begin
		print 'adding sql login [nsUser] (sp_addlogin)...'
		exec sp_addlogin 'nsUser', 'nsuser'

		--exec sp_defaultdb 'nsUser', 'nsdb'
	end

	if not exists (
		select *
		from master..syslogins
		where name = 'nsGuest'
		)
	begin
		print 'adding sql login [nsGuest] (sp_addlogin)...'
		exec sp_addlogin 'nsGuest', 'nsguest'

		--exec sp_defaultdb 'nsGuest', 'nsdb'
	end

--|Change object owners to allow users to be dropped
declare obj_cursor cursor
for
	select obj.name, usr.name
	from sysobjects obj
	join sysusers usr
	on obj.uid = usr.uid
	where obj.uid in (
		select uid
		from sysusers
		where name in ('nsadmin', 'nsuser', 'nsguest')
		)

open obj_cursor
fetch next from obj_cursor into @obj, @user
while @@fetch_status = 0
begin
	print 'Changing object ownership (sp_changeobjectowner)...'
	set @sql = 'exec sp_changeobjectowner ''' + @user + '.' + @obj + ''', ''dbo'''
	print 'Changed owner of ''' + @obj + ''' from ''' + @user + ''' to ''dbo''.'
	exec (@sql)

fetch next from obj_cursor into @obj, @user
end

close obj_cursor
deallocate obj_cursor
go

--|Drop/Add users to databases
	--|nsadmin
	if exists (select * from sysusers where name = N'nsadmin')
	begin
		print 'dropping user [nsAdmin] (sp_dropuser)...'
		exec sp_dropuser 'nsadmin'
	end
	go
	
	if not exists (select * from sysusers where name = N'nsadmin')
	begin
		exec sp_grantdbaccess N'nsadmin', N'nsadmin'
	end
	go
	
	exec sp_addrolemember N'db_owner',N'nsadmin'
	go
	

	--|nsuser
	if exists (select * from sysusers where name = N'nsuser')
	begin
		print 'dropping user [nsUser] (sp_dropuser)...'
		exec sp_dropuser 'nsuser'
	end
	go
	
	if not exists (select * from sysusers where name = N'nsuser')
	begin
		exec sp_grantdbaccess N'nsuser', N'nsuser'
	end
	go

	--|nsguest
	if exists (select * from sysusers where name = N'nsguest')
	begin
		print 'dropping user [nsGuest] (sp_dropuser)...'
		exec sp_dropuser 'nsguest'
	end
	go
	
	if not exists (select * from sysusers where name = N'nsguest')
	begin
		exec sp_grantdbaccess N'nsguest', N'nsguest'
	end
	go

--print '...You may need to run ''Grant Explicit Permissions (nsdb).sql'' to ensure users have appropriate access to db objects.'
declare @name varchar(256)
	,@type char(2)
	,@sql varchar(255)

declare sysobjects_cursor cursor
for 
	select [name], type
	from sysobjects
	where type in ('p', 'u')

open sysobjects_cursor
fetch next from sysobjects_cursor into @name, @type
while @@fetch_status = 0
begin
	select @sql = case @type
		when 'p' then 'grant execute on dbo.[' + @name + ']'
		when 'u' then 'grant select, update, insert on dbo.[' + @name + ']'
	end

	exec(@sql + ' to nsuser')
	print @sql + ' to nsuser'

fetch next from sysobjects_cursor into @name, @type
end

close sysobjects_cursor
deallocate sysobjects_cursor

