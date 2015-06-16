begin tran

set nocount on
/*
	This script is intended to update the UserName and/or UUID in the syncAccess database
	to match what the source system.

	Update the parameters by clicking CTRL+SHIFT+M

	Parameters:

	@email - *required.  necessary to find the subscriber in syncAccess
	@bloxUserName - This is the value we will use to update syncAccess.  Leave value empty for no update.
	@bloxUUID - This is the value we will use to update UUID in syncAccess.  Leave value empty for no update.

	** you must change the 'rollback tran' to 'commit tran' to make the update permanent
*/

declare @email nvarchar(256)
declare @bloxUserName nvarchar(1000)
declare @bloxUUID nvarchar(1000)
declare @msg nvarchar(200)

--|  Parameters  
set @email = '<email_address, sysname, subscriber@email.com>'
set @bloxUserName = '<blox_username, sysname, >'
set @bloxUUID = '<blox_uuid, sysname, >'

--|  Preview - This results set will show you what the values in syncAccess are before we update them.
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

--|  UserName exists in 2 tables (oAuthMembership & seUsers)
--|	oAuthMembership
if @bloxUserName <> ''
begin
	update OAuthMembership
	set UserName = @bloxUserName
	--	, ProviderUserID = 'e345bbdc-eb36-11e3-a3dd-10604ba09cc0'
	from subscribers s
	join seMemberships m
		on s.UserId = m.UserID
	join seUsers u
		on s.UserId = u.userid
	join OAuthMembership om
		on u.UserId = om.Id
	where m.Email = @email
	and om.UserName <> @bloxUserName
	set @msg = case @@rowcount 
			when 0 then 'No update to UserName required in oAuthMembership.'
			else 'Updated UserName in oAuthMembership to ' + @bloxUserName + '.'
			end
	print @msg

	--|seUsers
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
end

--|  UUID
if @bloxUUID <> ''
begin
	update OAuthMembership
	set ProviderUserID = @bloxUUID
	from subscribers s
	join seMemberships m
		on s.UserId = m.UserID
	join seUsers u
		on s.UserId = u.userid
	join OAuthMembership om
		on u.UserId = om.Id
	where m.Email = @email
	and om.ProviderUserID <> @bloxUUID
	set @msg = case @@rowcount 
			when 0 then 'No update to ProviderUserId required in oAuthMembership.'
			else 'Updated ProviderUserId in oAuthMembership to ' + @bloxUUID + '.'
			end
	print @msg
end

--|  Review - This shows you if the update was successful
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