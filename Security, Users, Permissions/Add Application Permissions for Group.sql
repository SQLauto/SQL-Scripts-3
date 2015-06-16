begin tran
/*
	Add Read/Write Permissions to all Applications

	If the group you specify does not exist, add the group
	If the user does not exists, add the user

	
*/

set nocount on

declare @GroupName varchar(100)

set @GroupName = 'System Administrators'

declare @GroupId int
select @GroupId = GroupId
from Groups 
where GroupName = @GroupName

if @GroupId is null
begin
	exec GroupCreate @GroupName=@GroupName, @ObjectType=NULL, @InsertUsers=NULL, @GroupId=@GroupId output
	print 'Added Group ''' + @GroupName + ''''
end

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

