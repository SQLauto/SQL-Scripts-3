

begin tran

set nocount on
/*
	This script is intended to delete users who can't be deleted via the web app
	because they own various objects or have audit history.
	
	Add any users you wish to delete to the #usersToDelete table.
*/
	create table #usersToDelete (username nvarchar(255))

	insert into #usersToDelete (username)
	select 'khead@wichitaeagle.com'
	union all select 'rdrury@sales.com'
	--union all select 'user3@syncronex.com'

	declare @userName nvarchar(255)
	declare @userId int
	declare @deletedUser int



	--|  Create the user '(deleted)'
		If Not Exists( Select 1	From dbo.Users where UserName = '(deleted)' )
		Begin
		print 'Creating new ''(deleted)'' user...'
			--
			--	Add the new '(deleted)' user since it doesn't already exist
			Insert dbo.Users( UserName, ObjectType )
			Values( '(deleted)',23182 )					-- use 23182 objecttype so we can exclude it from User Maint. Pages
			
			set @deletedUser = scope_identity()

			Insert dbo.logins(
				 UserID
				,NetworkPlatformID
				,NetworkLogon
				,Email
				,Password
				,PIN
				,SubscriberID
				,NDSContext
				,[Domain]
				,PasswordQuestion
				,PasswordAnswer
			)
			Values( @deletedUser,23100,NULL,'(deleted)',NULL,NULL,NULL,NULL,NULL,NULL,NULL )
		End
		
		select @deletedUser = UserId from dbo.Users where UserName = '(deleted)'

	--|  Update all references to user to delete

	declare user_cursor cursor
	for 
		select username
		from #usersToDelete
		
	open user_cursor
	fetch next from user_cursor into @userName
	while @@fetch_status = 0
	begin
		select @userId = UserId
		from Users
		where UserName = @userName

		update scReturnsAudit
		set RetAuditUserId = @deletedUser
		where RetAuditUserId = @userId
		print 'updated ' + cast(@@rowcount as nvarchar) + ' records in [scReturnsAudit]'

		update scDrawAdjustmentsAudit
		set AdjAuditUserId = @deletedUser
		where AdjAuditUserId = @userId
		print 'updated ' + cast(@@rowcount as nvarchar) + ' records in [scDrawAdjustmentsAudit]'

		update scManifestTemplates
		set MTOwner = @deletedUser
		where MTOwner  = @userId
		print 'updated ' + cast(@@rowcount as nvarchar) + ' records in [scManifestTemplates]'
		
		update scManifests
		set ManifestOwner = @deletedUser
		where ManifestOwner = @userId
		print 'updated ' + cast(@@rowcount as nvarchar) + ' records in [scManifests]'
		
		update scAccountsPubs
		set APOwner = @deletedUser
		where APOwner = @userId
		print 'updated ' + cast(@@rowcount as nvarchar) + ' records in [scAccountsPubs]'
		
		update scAccounts
		set AcctOwner = @deletedUser
		where AcctOwner = @userId
		print 'updated ' + cast(@@rowcount as nvarchar) + ' records in [scAccounts]'
		
		update scForecastRules
		set FROwner = @deletedUser
		where FROwner = @userId
		print 'updated ' + cast(@@rowcount as nvarchar) + ' records in [scForecastRules]'
		
		update nsMessages
		set nsToId = case nsToId
						when @userId then @deletedUser
						else nsToId
						end
			, nsFromId = case nsFromId
						when @userId then @deletedUser
						else nsFromId
						end
		where nsToId = @userId
		or nsFromId = @userId
		print 'updated ' + cast(@@rowcount as nvarchar) + ' records in [nsMessages]'

		update scReportsUsers 
		set UserId = @deletedUser
		where UserId = @userId
		print 'updated ' + cast(@@rowcount as nvarchar) + ' records in [scReportsUsers]'

		
		EXEC UserDelete @userId
		print 'User ''' + @userName + ''' deleted'
		print ''
			
		fetch next from user_cursor into @userName
	end


	close user_cursor
	deallocate user_cursor

	drop table #usersToDelete

commit tran