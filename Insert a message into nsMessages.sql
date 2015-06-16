
--| insert a message into nsMessages
		exec nsMessages_INSERTNOTALREADY 
			@nsSubject='Auto-Forecasting'
			, @nsMessageText=@msg
			, @nsFromId = 8
			, @nsToId = 0
			, @nsGroupId = 2
			, @nsTime = @date
			, @nsPriorityId = 2 	--|  Normal
			, @nsStatusId = 3  	--|
			, @nsTypeId = 1		--|  Memo 
			, @nsStateId = 1
			, @nsCompareTime = @date
			, @nsAccountId = 0