	declare @date datetime
	declare @user int

	set @date = getdate()
	select @user = UserId
	from Users
	where UserName = 'support@syncronex.com'

	exec nsMessages_INSERTNOTALREADY 
		@nsSubject='VDB PeriodStartDates Updated'
		, @nsMessageText=@msg
		, @nsFromId = @user
		, @nsToId = 0
		, @nsGroupId = 2
		, @nsTime = @date
		, @nsPriorityId = 2 	--|  Normal
		, @nsStatusId = 3  	--|
		, @nsTypeId = 1		--|  Memo 
		, @nsStateId = 1
		, @nsCompareTime = @date
		, @nsAccountId = 0