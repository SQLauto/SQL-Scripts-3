begin tran
/*
	Add Read/Write Permissions to all Applications

	If the group you specify does not exist, add the group
	If the user does not exists, add the user

	
*/

set nocount on

declare @GroupName varchar(100)
declare @UserName varchar(255)

set @GroupName = 'Support'
set @UserName = 'support@syncronex.com'

declare @GroupId int
select @GroupId = GroupId
from Groups 
where GroupName = @GroupName

if @GroupId is null
begin
	exec GroupCreate @GroupName=@GroupName, @ObjectType=NULL, @InsertUsers=NULL, @GroupId=@GroupId output
	print 'Added Group ''' + @GroupName + ''''
end

if not exists (
	select 1
	from Users
	where UserName = @UserName
)
begin
	--|  Add user using the same mechanism the web pages use
	declare @P1 int
	set @P1=4
	exec AuthenticationUserCreate @UserName, 23100, default, @UserName, 'zÃVÍ1ò™}ðÕ’•6³£', '7.»þç‘', null, null, null, '7.»þç‘', '7.»þç‘', null, @P1 output

	--|  Add the user to the Everyone Group
	SELECT GroupID INTO #GroupListWrk  FROM Groups Where GroupID IN (1) EXEC UserGroupUpdate @P1
	print 'Added User ''' + @UserName + ''''
end

if not exists (
	select 1 
	from UserGroups 
	where UserId = ( select UserId from Users where UserName = @UserName )
	and GroupId = @GroupId
)
begin
	--|  Now add the User to the Group you are creating
	insert into UserGroups (UserId, GroupId)
	select UserId, @GroupId
	from Users
	where UserName = @UserName
	print 'Added User ''' + @UserName + ''' to group ''' + @GroupName + ''''
end

insert into GroupACL (GroupId, SecuredObjectId, Category, AccessMask)
select @GroupId, SecuredObjectId, 23175, 3 
from securedobjects sec
where SecuredObjectId not in 
	(
	select SecuredObjectId
	from GroupACL
	where GroupId = @GroupId 
	)
print 'Granted Read/Write Permissions for all Applications'

select g.groupname as [Group Name]
	, sobj.description as [Application]
	, case accessmask 
		when 1 then 'Read Only' 
		when 2 then 'Write Only'
		when 3 then 'Read/Write'
	end as [Permissions]
from groups g
left join groupacl gacl
	on g.groupid = gacl.groupid
left join securedobjects sobj
	on gacl.securedobjectid = sobj.securedobjectid
where g.groupid = @GroupId
order by g.groupname, 3

commit tran

