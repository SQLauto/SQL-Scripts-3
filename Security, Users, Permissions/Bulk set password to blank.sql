
select UserID, Email, Password
into support_PasswordReset
from Logins


update Logins
set Password = null


update Logins
set Password = tmp.Password
from Logins l
join support_PasswordReset tmp
	on l.UserID = tmp.UserId

