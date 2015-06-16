begin tran

set nocount on
/*
Email address:  mjoanmorrison10@yahoo.com

BLOX UUID:        cfcdc7de-c660-11e3-acda-10604b9f0f84
Sync UUID:        cfcdc7de-c660-11e3-acda-10604b9f0f84

Sync User Name:            press100648443
BLOX User Name:            mmorrison10
*/

declare @syncUUID nvarchar(1000)
declare @bloxUUID nvarchar(1000)
declare @email nvarchar(256)
declare @bloxUserName nvarchar(1000)
declare @msg nvarchar(200)

set @email = 'mjoanmorrison10@yahoo.com'  
set @bloxUserName = 'mmorrison10'
set @bloxUUID = 'cfcdc7de-c660-11e3-acda-10604b9f0f84'

select s.UserId, m.Email, u.UserName as [UserName (seUsers)], om.UserName as [UserName (oAutMembership)]
	, om.Provider, om.ProviderUserID
from subscribers s
left join seMemberships m
	on s.UserId = m.UserID
left join seUsers u
	on s.UserId = u.userid
left join OAuthMembership om
	on u.UserId = om.Id
where m.Email = @email 

update OAuthMembership
set UserName = 'mmorrison10'
--	, ProviderUserID = 'e345bbdc-eb36-11e3-a3dd-10604ba09cc0'
from subscribers s
join seMemberships m
	on s.UserId = m.UserID
join seUsers u
	on s.UserId = u.userid
join OAuthMembership om
	on u.UserId = om.Id
where m.Email = 'mjoanmorrison10@yahoo.com'
and om.UserName <> @bloxUserName
set @msg = case @@rowcount 
		when 0 then 'No update to UserName required in oAuthMembership.'
		else 'Updated UserName in oAuthMembership to ' + @bloxUserName + '.'
		end
print @msg

update seUsers
set UserName = @bloxUserName
from seusers u
join seMemberships m
	on m.UserId = u.UserID
where m.Email = @email
and UserName <> @bloxUserName
set @msg = case @@rowcount 
		when 0 then 'No update to UserName required in seUsers.'
		else 'Updated UserName in seUsers to ' + @bloxUserName + '.'
		end
print @msg

update OAuthMembership
set ProviderUserID = @bloxUUID
from subscribers s
join seMemberships m
	on s.UserId = m.UserID
join seUsers u
	on s.UserId = u.userid
join OAuthMembership om
	on u.UserId = om.Id
where m.Email = 'mjoanmorrison10@yahoo.com'
and om.ProviderUserID <> @bloxUUID
set @msg = case @@rowcount 
		when 0 then 'No update to ProviderUserId required in oAuthMembership.'
		else 'Updated ProviderUserId in oAuthMembership to ' + @bloxUUID + '.'
		end
print @msg


select s.UserId, m.Email, u.UserName as [UserName (seUsers)], om.UserName as [UserName (oAutMembership)]
	, om.Provider, om.ProviderUserID
from subscribers s
left join seMemberships m
	on s.UserId = m.UserID
left join seUsers u
	on s.UserId = u.userid
left join OAuthMembership om
	on u.UserId = om.Id
where m.Email = @email 

rollback tran