begin tran
/*
	Add Read/Write Permissions to all Applications

	If the group you specify does not exist, add the group
	If the user does not exists, add the user

	
*/
use sdmconfig

set nocount on

declare @GroupName varchar(100)
declare @UserName varchar(255)
declare @mtDisplatyName varchar(255)
declare @webOrWireless varchar(8)

set @GroupName = 'Home Delivery Advisors'
set @UserName = '9132307312@messaging.sprintpcs.com'
set @mtDisplatyName = 'Test (913-230-7312) - Sprint'
set @webOrWireless = 'Web'

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
	exec AuthenticationUserCreate @UserName, 23100, default, @UserName, 'zÃVÍ1ò™}ðÕ’•6³£', '7.»þç‘', null, null, null, '7.»þç‘', '7.»þç‘', @P1 output

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

insert into SDMData..deMessageTarget (messagetargetdisplayname, syncronexusername, extensionattribute1 )
select @mtDisplatyName, @username, @webOrWireless
print 'Added Message Target ''' + @mtDisplatyName + ''' for User ''' + @UserName + ''''

commit tran

