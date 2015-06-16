--|  use for restored backups of SingleCopy databases


--|Add Users
	if not exists (
		select *
		from master..syslogins
		where name = 'dmconfig'
		)
	begin
		exec sp_addlogin 'dmconfig', 'dmconfig'
	end

	
	if not exists (
		select *
		from master..syslogins
		where name = 'dmweb'
		)
	begin
		exec sp_addlogin 'dmweb', 'dmweb'
	end


--|Change object owners to allow users to be dropped
declare @obj nvarchar(255)
declare @user nvarchar(50)
declare @sql nvarchar(2048)

declare obj_cursor cursor
for
	select obj.name, usr.name
	from sysobjects obj
	join sysusers usr
	on obj.uid = usr.uid
	where obj.uid in (
		select uid
		from sysusers
		where name in ('dmconfig', 'dmweb')
		)

open obj_cursor
fetch next from obj_cursor into @obj, @user
while @@fetch_status = 0
begin
	set @sql = 'exec sp_changeobjectowner ''' + @user + '.' + @obj + ''', ''dbo'''
	print 'Changed owner of ''' + @obj + ''' from ''' + @user + ''' to ''dbo''.'
	exec (@sql)

fetch next from obj_cursor into @obj, @user
end

close obj_cursor
deallocate obj_cursor
go


exec sp_changedbowner 'sa'

--|Drop/Add users to databases
	--|dmconfig
	if exists (select * from sysusers where name = N'dmconfig')
	begin
		exec sp_dropuser 'dmconfig'
	end
	go
	
	if not exists (select * from sysusers where name = N'dmconfig')
	begin
		exec sp_grantdbaccess N'dmconfig', 'dmconfig'
	end
	go
	
	exec sp_addrolemember 'db_owner','dmconfig'
	go
	

	--|dmweb
	if exists (select * from sysusers where name = N'dmweb')
	begin
		exec sp_dropuser 'dmweb'
	end
	go
	
	if not exists (select * from sysusers where name = N'dmweb')
	begin
		exec sp_grantdbaccess N'dmweb', N'dmweb'
	end
	go

	exec sp_addrolemember 'db_owner','dmweb'
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
		when 'p' then 'grant execute on dbo.' + @name
		when 'u' then 'grant select, update, insert on dbo.' + @name
	end

	exec(@sql + ' to dmweb')
	print @sql + ' to dmweb'

fetch next from sysobjects_cursor into @name, @type
end

close sysobjects_cursor
deallocate sysobjects_cursor

