


select u.UserID, u.UserName, l.Password, 'update logins set password = ''' + l.Password + ''' where userid = ' + CAST(l.UserID as varchar)
from Users u
join Logins l
	on u.UserID = l.UserID
where UserName not in (
	 'support@syncronex.com'	
	, 'dhorne@mg.com'
	, 'dhorne1@mg.com' )

update logins set password = 'zÃVÍ1ò™}ðÕ’•6³£' where userid = 4
update logins set password = 'abc123' where userid = 4

select *
from users

where username like 'dh%'