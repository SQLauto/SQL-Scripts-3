

begin tran
/*
	Add Read/Write Permissions to all Applications

	If the group you specify does not exist, add the group
	If the user does not exists, add the user

	
*/

set nocount on

declare @GroupName varchar(100)
declare @AccessMask int
declare @GroupId int
declare @UserName varchar(255)
declare @Pin varchar(100)
declare @Password varchar(100)

create table #users (
	  UserId int
	, UserName nvarchar(25)
	, Password varchar(100)
	, PIN varchar(100)
)

create table #groups (
	GroupName nvarchar(25)
	, Description varchar(100)
	, AccessMask int
)

create table #usergroups (
	UserName varchar(25)
	, GroupName nvarchar(25)
	, GroupId int
)

insert into #users ( UserId, UserName, Password, PIN )
select u.UserId, UserName, Password, PIN
from nsdb_36..Users u
join nsdb_36..Logins l
	on u.UserID = l.UserID
where UserName = '<user_name,sysinfo,support@syncronex.com>' 	

insert into #usergroups (UserName, GroupName, GroupId)
select u.UserName, g.GroupName, g.GroupID
from #users u
join nsdb_36..UserGroups ug
	on u.UserID = ug.UserID
join nsdb_36..Groups g
	on ug.GroupID = g.GroupID

insert into #groups ( GroupName, Description, AccessMask )
select g.GroupName, Description, AccessMask
from nsdb_36..Groups g
join nsdb_36..GroupACL gacl
	on g.GroupID = gacl.GroupID
join nsdb_36..SecuredObjects obj
	on gacl.SecuredObjectID = obj.SecuredObjectID
join #usergroups ug
	on g.GroupID = ug.GroupId	


declare group_cursor cursor
for 
	select distinct tmp.GroupName
	from #groups tmp
	left join Groups g
		on tmp.GroupName = g.GroupName
	where g.GroupId is null
	

open group_cursor
fetch next from group_cursor into @GroupName
while @@FETCH_STATUS = 0
begin
	select @GroupId = GroupId
	from Groups
	where GroupName = @GroupName
		
	if @GroupId is null
	begin
		exec GroupCreate @GroupName=@GroupName, @ObjectType=NULL, @InsertUsers=NULL, @GroupId=@GroupId output
		print 'Added Group ''' + @GroupName + ''''
	end
	
	insert into GroupACL (GroupId, SecuredObjectId, Category, AccessMask)
	select g.GroupId, obj.SecuredObjectId, 23175, tmp.AccessMask 
	from #groups tmp
	join Groups g
		on tmp.GroupName = g.GroupName
	join SecuredObjects obj
		on tmp.Description = obj.Description
	left join GroupACL gacl
		on g.GroupID = gacl.GroupID
		and obj.SecuredObjectID = gacl.SecuredObjectID		
	where gacl.GroupACLID is null
	
	
	fetch next from group_cursor into @GroupName
end

close group_cursor
deallocate group_cursor

declare user_cursor cursor
for 
	select tmp.UserName, tmp.Password, tmp.PIN
	from #users tmp
	left join users u
		on tmp.UserName = u.UserName
	where u.UserId is null
	
open user_cursor
fetch next from user_cursor into @UserName, @Password, @PIN
while @@FETCH_STATUS = 0 
begin
	if not exists (
		select 1
		from Users
		where UserName = @UserName
	)
	begin
		--|  Add user using the same mechanism the web pages use
		declare @P1 int
		--set @P1=null
		exec AuthenticationUserCreate @UserName, 23100, default, @UserName, @Password, @Pin, null, null, null, '7.»þç‘', '7.»þç‘', null, @P1 output

		--|  Add the user to the Everyone Group
		SELECT GroupID INTO #GroupListWrk  FROM Groups Where GroupID IN (1) EXEC UserGroupUpdate @P1
		print 'Added User ''' + @UserName + ''' (UserId=' + cast(@P1 as varchar) + ')' 
	end

	insert into UserGroups (UserId, GroupId)
	select u.UserID, g.GroupID
	from #usergroups tmp
	join Users u
		on tmp.UserName = u.UserName
	join Groups g
		on tmp.GroupName = g.GroupName
	left join UserGroups ug
		on u.UserID = ug.UserID
		and g.GroupID = ug.GroupID
	where tmp.UserName = @UserName
	and ( ug.UserID is null )
			
		
	print 'Added User ''' + @UserName + ''' to ''' + cast(@@rowcount as varchar)+ ''' groups'



fetch next from user_cursor into @UserName, @Password, @PIN
end

close user_cursor
deallocate user_cursor

drop table #users
drop table #usergroups
drop table #groups



	select
		u.UserName 
		, g.groupname as [Group Name]
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
	join UserGroups ug
		on g.GroupID = ug.GroupID
	join Users u 
		on ug.UserID = u.UserID	
	order by u.UserName, Application
	
commit tran



