

begin tran

select *
from dedistrict
where sdm_district = 'e230'

update dedistrict
set sdm_isactive = 1
where sdm_district = 'e230'

select *
from dedistrict
where sdm_district = 'e230'

commit tran