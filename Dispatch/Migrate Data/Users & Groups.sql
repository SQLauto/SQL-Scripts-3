begin tran

set identity_insert sdmconfig..users on	

insert into users ( UserID, UserName, ObjectType )
select cct.userid, cct.username, cct.objecttype
from sdmconfig_cct..users cct
left join users u
	on cct.username = u.username
where u.userid is null
order by cct.userid

set identity_insert sdmconfig..users off	
insert into logins
select l.*
from sdmconfig_cct..logins l
join users u
	on l.userid = u.userid
order by userid


declare @maxId int

select @maxId = isnull( max(GroupFlag), 0 ) + 1
from Groups

print @maxid

select Id = identity(int,24,1)
	, tmp.GroupName
into #newGroups	
from SDMConfig_CCT..Groups tmp
left join Groups g
	on tmp.GroupName = g.GroupName
where g.GroupId is null

set identity_insert groups on

insert into Groups ( GroupID, GroupFlag, GroupName, ObjectType )
select Id, Id, GroupName, '23180'
from #newGroups

set identity_insert groups off

drop table #newGroups


insert into usergroups
select g.groupid, u.userid
from users u
join (
	select username, groupname
	from sdmconfig_cct..users u
	join sdmconfig_cct..usergroups ug
		on u.userid = ug.userid
	join sdmconfig_cct..groups g
		on ug.groupid = g.groupid
	where g.groupid <> 1
	and u.userid <> 142
	) cct
	on u.username = cct.username
join groups g
	on cct.groupname = g.groupname

commit tran
