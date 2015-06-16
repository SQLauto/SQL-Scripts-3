begin tran

set nocount on

;with cte as (
	select u.UserId, a.AccountID
	from support_inactiveftlsyncronexusers tmp
	join Users u
		on tmp.[Column 0] = u.UserName
	left join scAccounts a
		on u.UserID = a.AcctOwner
)
update scAccounts 
set AcctOwner = 135
from scAccounts a
join cte 
	on cte.AccountID = a.AccountID
print cast(@@rowcount as varchar) + ' scAccounts records updated'	

;with cte as (
	select u.UserId, ap.AccountPubID
	from support_inactiveftlsyncronexusers tmp
	join Users u
		on tmp.[Column 0] = u.UserName
	join scAccountsPubs ap
		on u.UserID = ap.APOwner	

)
update scAccountsPubs 
set APOwner = 135
from scAccountsPubs ap
join cte
	on ap.AccountPubID = cte.AccountPubID	
print cast(@@rowcount as varchar) + ' scAccountsPubs records updated'

;with cte as (
	select u.UserId, mt.ManifestTemplateId
	from support_inactiveftlsyncronexusers tmp
	join Users u
		on tmp.[Column 0] = u.UserName
	join scManifestTemplates mt
		on u.UserID = mt.MTOwner	
)	
update scManifestTemplates
set MTOwner = 135
from scManifestTemplates mt
join cte	

	on mt.ManifestTemplateId = cte.ManifestTemplateId
print cast(@@rowcount as varchar) + ' scManifestTemplates records updated'

;with cte as (
	select u.UserId, mt.ManifestTemplateId
	from support_inactiveftlsyncronexusers tmp
	join Users u
		on tmp.[Column 0] = u.UserName
	join scManifestTemplates mt
		on u.UserID = mt.MTOwner	
)	
update scManifests
set ManifestOwner = 135
from scManifests m
join cte	
	on m.ManifestTemplateId = cte.ManifestTemplateId
print cast(@@rowcount as varchar) + ' scManifests records updated'

;with cte as (
	select u.UserId
	from support_inactiveftlsyncronexusers tmp
	join Users u
		on tmp.[Column 0] = u.UserName
)
--update nsDevicesUsers
--set UserId = 135
delete du
from nsDevicesUsers du
join cte tmp
	on du.UserID = tmp.UserID
print cast(@@rowcount as varchar) + ' nsDevicesUsers records deleted'

;with cte as (
	select u.UserId
	from support_inactiveftlsyncronexusers tmp
	join Users u
		on tmp.[Column 0] = u.UserName
)
update scReturnsAudit
set RetAuditUserId = 135
from scReturnsAudit ra
join cte 
	on ra.RetAuditUserId = cte.UserID
print cast(@@rowcount as varchar) + ' scReturnsAudit records updated'	

;with cte as (
	select u.UserId
	from support_inactiveftlsyncronexusers tmp
	join Users u
		on tmp.[Column 0] = u.UserName
)
update scDrawAdjustmentsAudit
set AdjAuditUserId = 135
from scDrawAdjustmentsAudit aa
join cte 
	on aa.AdjAuditUserId = cte.UserID
print cast(@@rowcount as varchar) + ' scDrawAdjustmentsAudit records updated'	
	
;with cte as (
	select u.UserId
	from support_inactiveftlsyncronexusers tmp
	join Users u
		on tmp.[Column 0] = u.UserName
)
delete em
from UserEmailAddresses em
join cte tmp
	on em.UserID = tmp.UserID
print cast(@@rowcount as varchar) + ' UserEmailAddress records deleted'	
	
;with cte as (
	select u.UserId
	from support_inactiveftlsyncronexusers tmp
	join Users u
		on tmp.[Column 0] = u.UserName
)
delete l
from Logins l
join cte tmp
	on l.UserID = tmp.UserID
print cast(@@rowcount as varchar) + ' Logins records deleted'	

;with cte as (
	select u.UserId
	from support_inactiveftlsyncronexusers tmp
	join Users u
		on tmp.[Column 0] = u.UserName
)
delete ug
from UserGroups ug
join cte tmp
	on ug.UserID = tmp.UserID
print cast(@@rowcount as varchar) + ' UserGroups records deleted'

;with cte as (
	select u.UserId
	from support_inactiveftlsyncronexusers tmp
	join Users u
		on tmp.[Column 0] = u.UserName
)
delete u
from Users u
join cte tmp
	on u.UserID = tmp.UserID
print cast(@@rowcount as varchar) + ' Users records deleted'

rollback tran	