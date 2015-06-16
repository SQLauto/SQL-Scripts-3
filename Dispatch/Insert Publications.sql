
begin tran

declare @maxId int

select @maxId = isnull( max(SDM_PubId), 0 )
from nsPublications

select SDM_PubId=identity(int,1,1)
	, Pub as [SDM_PubAbbreviation]
	, Pub as [SDM_PubName]
	, PubCode as [SDM_ExtensionAttribute1]
into #pubs
from (
	select distinct publicationabbrev as [Pub]
		, publicationcode as pubCode
	from SDMData_CCT..Message m
	left join nsPublications p
		on m.publicationabbrev = p.SDM_PubAbbreviation
	where SDM_PubId is null
	) as [Pubs]
order by 2

insert into nsPublications ( SDM_PubId, SDM_PubAbbreviation, SDM_PubName, SDM_ExtensionAttribute1, SDM_IsActive )
select @maxId + SDM_PubId as [SDM_PubId]
	, SDM_PubAbbreviation
	, SDM_PubName
	,  SDM_ExtensionAttribute1
	, 1
from #pubs

drop table #pubs

select *
from nsPublications

commit tran

insert into dezone ( SDM_Zone, SDM_ZoneDisplayName )
select distinct zonenumber, zonenumber
from sdmdata_cct..message
order by zonenumber

select distinct district, zonenumber
from sdmdata_cct..message
order by zonenumber

select distinct sdm_zone
from dedistrict

update dedistrict
set sdm_zone = zonenumber
from ( 
	select distinct district, zonenumber
	from sdmdata_cct..message
	) z
join deDistrict d
	on z.district = d.sdm_district

