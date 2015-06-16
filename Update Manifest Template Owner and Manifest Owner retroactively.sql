begin tran

declare @retroactiveDate datetime
set @retroactiveDate = '5/27/2011'

create table support_ManifestOwners (mfstcode nvarchar(4), manifestowner nvarchar(50) )

insert into support_ManifestOwners
select 'F010', 'burnham@journalsentinel.com'
union all select 'F015', 'burnham@journalsentinel.com'
union all select 'F020', 'burnham@journalsentinel.com'
union all select 'F025', 'burnham@journalsentinel.com'
union all select 'F030', 'burnham@journalsentinel.com'
union all select 'F035', 'burnham@journalsentinel.com'
union all select 'F040', 'burnham@journalsentinel.com'
union all select 'F050', 'cedarburg@journalsentinel.com' 
union all select 'F100', 'clinton@journalsentinel.com'
union all select 'F150', 'hartland@journalsentinel.com'
union all select 'F250', 'mfalls@journalsentinel.com'
union all select 'F300', 'muskego@journalsentinel.com'
union all select 'F350', 'portwashington@journalsentinel.com'
union all select 'F450', 'rawson@journalsentinel.com'
union all select 'F455', 'rawson@journalsentinel.com'
union all select 'F460', 'rawson@journalsentinel.com'
union all select 'F465', 'rawson@journalsentinel.com'
union all select 'F470', 'rawson@journalsentinel.com'
union all select 'F500', 'waukesha@journalsentinel.com'
union all select 'F505', 'waukesha@journalsentinel.com'
union all select 'F600', 'westbend@journalsentinel.com'
union all select 'F650', 'hartford@journalsentinel.com'

update scManifestTemplates
set MTOwner = u.UserId
from support_ManifestOwners mo
join scManifestTemplates mt
	on mo.mfstcode = mt.mtcode
join users u
	on mo.manifestowner = u.username

update scManifests
set ManifestOwner = MTOwner
from scManifestTemplates mt
join scManifests m
	on mt.ManifestTemplateId = m.ManifestTemplateId
join support_ManifestOwners mo
	on mt.mtcode = mo.mfstcode
and m.ManifestDate >= @retroactiveDate

drop table support_ManifestOwners


select m.manifestdate, m.mfstcode, m.manifestowner, mt.mtowner
from scmanifesttemplates mt
join scmanifests m
	on mt.manifesttemplateid = m.manifesttemplateid
where mtcode in (
	  'F010'
	, 'F015'
	, 'F020'
	, 'F025'
	, 'F030'
	, 'F035'
	, 'F040'
	, 'F050' 
	, 'F100'
	, 'F150'
	, 'F250'
	, 'F300'
	, 'F350'
	, 'F450'
	, 'F455'
	, 'F460'
	, 'F465'
	, 'F470'
	, 'F500'
	, 'F505'
	, 'F600'
	, 'F650'
	)

commit tran

