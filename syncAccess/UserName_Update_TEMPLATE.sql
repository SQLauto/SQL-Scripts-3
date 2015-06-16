/*
	Use CTRL+SHIFT+M to replace variables with their appropriate values
*/

begin tran

use <company,sysinfo,scripps>_<property,sysinfo,property>_<stage_or_prod,sysinfo,prod>

set nocount on

if  exists (
	select * from sys.objects where object_id = object_id(N'[dbo].[support_username_update]') and type in (N'U')
)
drop table [dbo].[support_username_update]  
GO

create table dbo.support_UserName_Update (
	username varchar(256)
	, email varchar(256)
)

bulk insert <company,sysinfo,scripps>_<property,sysinfo,property>_<stage_or_prod,sysinfo,prod>..support_UserName_Update
from 'C:\Syncronex\Syncronex_Support\<property,sysinfo,property>.csv'
with (
	FIELDTERMINATOR = ','
)

select m.UserID, m.Email, u.UserName, tmp.username as [NewUserName]
into support_UserName_Update_Backup
from support_UserName_Update tmp
left join seMemberships m
	on ltrim(rtrim(tmp.email)) = ltrim(rtrim(m.email))
left join seUsers u
	on m.UserID = u.UserId 
--where u.UserId is not null
where ltrim(rtrim(u.UserName)) <> ltrim(rtrim(tmp.username))
print cast(@@rowcount as varchar) + ' usernames backed up'

select *
from support_UserName_Update_Backup

update seUsers
set UserName = tmp.username
from support_UserName_Update tmp
join seMemberships m
	on ltrim(rtrim(tmp.email)) = ltrim(rtrim(m.email))
join seUsers u
	on m.UserID = u.UserId 
where ltrim(rtrim(u.UserName)) <> ltrim(rtrim(tmp.username))
print cast(@@rowcount as varchar) + ' usernames updated'

<rollback_or_commit,sysinfo,rollback> tran