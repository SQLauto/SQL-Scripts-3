
insert into dezone ( SDM_Zone, SDM_ZoneDisplayName )
select distinct zonenumber, zonenumber
from sdmdata_cct..message
order by zonenumber


update dedistrict
set sdm_zone = zonenumber
from ( 
	select distinct district, zonenumber
	from sdmdata_cct..message
	) z
join deDistrict d
	on z.district = d.sdm_district

