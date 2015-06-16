/*

use this script to insert users into the sdmconfig..users table if you have a source table to derive the usernames from

*/

begin tran

insert into sdmconfig..users (username, objecttype)
select syncronexusername, 23180
from demessagetarget
where syncronexusername not in
	(
	select username
	from sdmconfig..users
	)

insert into sdmconfig..logins (userid, email, networkplatformid, networklogon, ndscontext, domain)
select userid, username, 23100, null, null, null 		--Note:  23100 is syncronex user, 23102 is the networkplatformid for windows authentication
from sdmconfig..users 
where userid not in 
	(
	select userid
	from sdmconfig..logins
	)

update sdmconfig..logins
set password = (select password from sdmconfig..logins where userid = 1)
	,pin = (select pin from sdmconfig..logins where userid = 1)
	,passwordanswer = (select passwordanswer from sdmconfig..logins where userid = 1)
where userid not in (2,3)

insert into sdmconfig..usergroups (groupid, userid)
select 1, userid
from sdmconfig..users
where userid not in (1, 2,3)

select *
from sdmconfig..users

select *
from sdmconfig..logins


commit tran

/*
dbcc checkident ('sdmconfig..users', reseed, 4)
dbcc checkident ('sdmconfig..logins', reseed, 4)
*/