

begin tran

select distinct mt.manifesttemplateid
	--, m.manifestid
	--, m.manifestdate
	, m.manifestowner, mu.username as [ManifestOwnerName]
	, mt.mtowner, mtu.username as [ManifestTemplateOwnerName]
	
	into support_ManifestOwners_Backup_02252014
	from scmanifesttemplates mt
	join scmanifests m
		on mt.manifesttemplateid = m.manifesttemplateid
	join users mu
		on m.manifestowner = mu.userid
	join users mtu
		on mt.mtowner = mtu.userid
	where m.manifestowner <> mt.mtowner	

select *
from support_ManifestOwners_Backup_02252014

;with cteOwner as (
	select distinct mt.manifesttemplateid
	--, m.manifestid
	--, m.manifestdate
	, m.manifestowner, mt.mtowner
	from scmanifesttemplates mt
	join scmanifests m
		on mt.manifesttemplateid = m.manifesttemplateid
	where m.manifestowner <> mt.mtowner	
)
update scManifests 
set ManifestOwner = MTOwner
from scManifests m
join cteOwner cte
	on m.ManifestTemplateId = cte.ManifestTemplateId


commit tran