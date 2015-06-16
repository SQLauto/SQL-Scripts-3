begin tran

/*
	This script assumes that the user that will be made the retroactive owner of the historical manifests is the current owner of the manifests
	
	The script will take the current owner of the Manifest and retroactively make them the owner of the corresponding historical manifests through
	the "Retroactive Date"

*/

declare @retroactiveDate datetime
declare @owner nvarchar(50)


set @retroactiveDate = '4/18/2010'
set @owner = 'lewisd@mts.net'

--|  Manifest Templates currently owned by the "new" manifest ow
select MTCode, u.UserName as [MTOwner]
from scManifestTemplates mt
join Users u
	on mt.MTOwner = u.UserId
where u.UserName = @owner
order by MTCode


select MTCode, m.ManifestDate, u.UserName as [MTOwner], u2.UserName as [ManifestOwner]
from scManifestTemplates mt
join Users u
	on mt.MTOwner = u.UserId
join scManifests m
	on mt.ManifestTemplateId = m.ManifestTemplateId
join Users u2
	on m.ManifestOwner = u2.UserId
where u.UserName = @owner
and m.ManifestDate >= @retroactiveDate
order by MTCode, m.ManifestDate

update scManifests
set ManifestOwner = MTOwner
from scManifestTemplates mt
join Users u
	on mt.MTOwner = u.UserId
join scManifests m
	on mt.ManifestTemplateId = m.ManifestTemplateId
where u.UserName = @owner
and m.ManifestDate >= @retroactiveDate

select MTCode, m.ManifestDate, u2.UserName as [Current Manifest Owner], u.UserName as [New Manifest Owner]
from scManifestTemplates mt
join Users u
	on mt.MTOwner = u.UserId
join scManifests m
	on mt.ManifestTemplateId = m.ManifestTemplateId
join Users u2
	on m.ManifestOwner = u2.UserId
where u.UserName = @owner
and m.ManifestDate >= @retroactiveDate
order by MTCode, m.ManifestDate


commit tran