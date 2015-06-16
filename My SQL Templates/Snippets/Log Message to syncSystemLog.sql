	declare @msg nvarchar(1024)
	
	set @msg = ''
    print @msg
    exec nsSystemLog_Insert 2, 0, @msg