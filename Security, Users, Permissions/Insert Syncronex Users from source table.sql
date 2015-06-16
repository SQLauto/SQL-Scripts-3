begin tran

insert into sdmconfig..users (username, objecttype)
select distinct Phone + '@mtm.com', 23180
from tmpTargets
where Phone not like '%T/B/A%'

insert into sdmconfig..logins (userid, email, networkplatformid, networklogon, ndscontext, domain)
select userid, username, 23102, null, null, null --Note:  23102 is the networkplatformid for windows authentication
from sdmconfig..users u
where userid not in ( 1, 2, 3 )

update sdmconfig..logins
set password = 'žøÕXrL á}¹\.„ÔT' --Password1
	,pin = 'C·YöøöjÎ' --1111
	--,passwordanswer = (select passwordanswer from sdmconfig..logins where userid = 3)
where userid not in (1,2,3)

insert into sdmconfig..usergroups (groupid, userid)
select 1, userid
from sdmconfig..users
where userid not in (1,2,3)

select *
from sdmconfig..users

select *
from sdmconfig..logins


commit tran