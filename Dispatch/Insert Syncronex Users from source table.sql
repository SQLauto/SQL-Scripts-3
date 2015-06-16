begin tran

insert into sdmconfig..users (username, objecttype)
select username, 23180
from seattletimesusers

insert into sdmconfig..logins (userid, email, networkplatformid, networklogon, ndscontext, domain)
select userid, username, 23102, null, null, null --Note:  23102 is the networkplatformid for windows authentication
from sdmconfig..users 
where userid not in (1, 2,3)

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


rollback tran