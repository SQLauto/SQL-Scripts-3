begin tran
	set nocount on

	declare @userid int
	declare @operatorId int

	select @operatorId = UserId
	from seUsers
	where UserName = 'syncadmin'

	select COUNT(*) as [Users in Database]
	from support_NullAcctsToDelete tmp
	join seMemberships m
		on tmp.UserId = m.UserID
		and tmp.Email = m.Email

	declare userdelete_cursor cursor
	for 
		select m.UserID
		from support_NullAcctsToDelete tmp
		join seMemberships m
			on tmp.UserId = m.UserID
			and tmp.Email = m.Email

	open userdelete_cursor
	fetch next from userdelete_cursor into @userid
	while @@FETCH_STATUS = 0
	begin
		
		exec Subscribers_Delete @UserId=@userid, @OperatorId=@operatorId
		
	fetch next from userdelete_cursor into @userid
	end
	
	close userdelete_cursor
	deallocate userdelete_cursor

	select COUNT(*) as [Users in Database]
	from support_NullAcctsToDelete tmp
	join seMemberships m
		on tmp.UserId = m.UserID
		and tmp.Email = m.Email


commit tran