begin tran

set nocount on

declare @user nvarchar(100)

declare @pwd nvarchar(100)
declare @sql nvarchar(1000)

set @user = 'w07@calgarysun.com'

select @pwd = [password]
from logins
where email = @user

set @sql = '
			update logins
			set password = ''' + @pwd + '''
			where email = ''' + @user + ''''

--|copy and execute the results of this print statement to reset the password to it's original value
print @sql

update logins
set [password] = null
where email = @user


commit tran