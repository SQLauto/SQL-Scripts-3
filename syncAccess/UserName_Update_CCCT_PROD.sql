begin tran

	set nocount on

	declare @dbcatalog nvarchar(20)
	declare @sql nvarchar(2000)
	declare @path nvarchar(200)
	
	set @dbcatalog = 'scripps_ccct_prod'
	select @path = 'C:\Users\Syncronex\Desktop\syncronex support\scripps\CCCT Username Export.txt'

	--|clear out the table if it exists, otherwise we need to create the table
	set @sql = '
	if  exists (
		select * from sys.objects where object_id = object_id(N''' + @dbcatalog + '..[support_username_update]'') and type in (N''U'')
	)
	begin
		print ''deleting ' + @dbcatalog + '..support_UserName_Update...''
		delete from ' + @dbcatalog + '..support_UserName_Update
	end
	else 
	begin
		print ''creating table [' + @dbcatalog + ']..[support_UserName_Update]...''
		create table ' + @dbcatalog + '..support_UserName_Update (
			username varchar(256)
			, email varchar(256)
		)
	end
	'
	--print @sql
	exec (@sql)
	
	--|  perform the bulk insert
	set @sql = 'bulk insert ' + @dbcatalog + '..support_UserName_Update
	from ''' + @path + '''
	with (
		FIELDTERMINATOR = ''\t''
	)
	print cast(@@rowcount as varchar) + '' usernames imported from file.''
	'

	--print @sql
	exec (@sql)
	
	--|  backup up operation to allow for rollback
	declare @bkp_name nvarchar(50)
	set @bkp_name = @dbcatalog + '..support_UserName_Backup_' + right('00' + cast(datepart(mm, getdate()) as varchar),2)
		+ right('00' + cast(datepart(DD, getdate()) as varchar),2)
		+ right('0000' + cast(datepart(yyyy, getdate()) as varchar),4)
		+ '_'
		+ right('00' + cast(datepart(hh, getdate()) as varchar),2)
		+ right('00' + cast(datepart(minute, getdate()) as varchar),2)
		+ right('0000' + cast(datepart(ss, getdate()) as varchar),2)
	
	set @sql = 'select m.UserID, m.Email, u.UserName as [UserName_seUsers], tmp.username as [UserName_New]
	into ' + @bkp_name + '
	from support_UserName_Update tmp
	join seMemberships m
		on ltrim(rtrim(tmp.email)) = ltrim(rtrim(m.email))
	join seUsers u
		on m.UserID = u.UserId 
	where ltrim(rtrim(u.UserName)) <> ltrim(rtrim(tmp.username))
	print cast(@@rowcount as varchar) + '' usernames backed up to table ' + @bkp_name + ''''

	--print @sql
	exec (@sql)

	set @sql = '
	update seUsers
	set UserName = tmp.username
	from ' + @dbcatalog + '..support_UserName_Update tmp
	join seMemberships m
		on ltrim(rtrim(tmp.email)) = ltrim(rtrim(m.email))
	join seUsers u
		on m.UserID = u.UserId 
	where ltrim(rtrim(u.UserName)) <> ltrim(rtrim(tmp.username))
	print cast(@@rowcount as varchar) + '' usernames updated''
	'
	--print @sql
	exec (@sql)
	
rollback tran