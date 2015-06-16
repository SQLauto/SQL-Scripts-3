begin tran

	set nocount on

	declare @username varchar(256)
	declare @userid int
	declare @msg nvarchar(500)

	set @username = 'tntlindag@aol.com'

	if not exists (
		select u.userid
		from seusers u
		left join subscribers s
			on u.userid = s.userid
		where username = @username
		and s.userid is null
	)
	begin
		print 'No duplicate seUser accounts found.'
		select u.userid, count(*)
		from seusers u
		left join subscribers s
			on u.userid = s.userid
		where username = @username
		group by u.userid
	end
	else
	begin
		select @msg = 'Duplicate seUsers records found.  Rowcount=' + cast(count(*) as varchar) + '.'
		from seusers u
		left join subscribers s
			on u.userid = s.userid
		where u.UserName = @username
		group by u.UserName
		print @msg

		select @userid = u.userid
		from seusers u
		left join subscribers s
			on u.userid = s.userid
		where username = @username
		and s.userid is null

		select @msg = 'Deleting user with no corresponding subscriber record.  UserId=' + cast(u.UserId as varchar) + '.'
		from seusers u
		left join subscribers s
			on u.userid = s.userid
		where username = @username
		and s.userid is null
		print @msg

		delete u
		from seusers u
		left join subscribers s
			on u.userid = s.userid
		where username = @username
		and s.userid is null
		print cast(@@rowcount as varchar) + case when @@rowcount=1 then ' record deleted from seUsers' else ' records deleted from seUsers' end


		select @msg = 'New seUsers rowcount=' + cast(count(*) as varchar) + '.'
		from seusers u
		left join subscribers s
			on u.userid = s.userid
		where u.UserName = @username
		group by u.UserName
		print @msg

	end

rollback tran