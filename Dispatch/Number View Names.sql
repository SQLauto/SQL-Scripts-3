begin tran

use sdmconfig

update t2k_site
set sitename = case siteid
		when 11 then ' 1. Message'
		when 25 then ' 2. Message - History'
		when 16 then ' 3. Schedule Detail'
		when 15 then ' 4. Message Target'
		when  3 then ' 5. System Log'
		when 18 then ' 6. Company'
		when 12 then ' 7. Distribution Centers'
		when 17 then ' 8. Zones'
		when 13 then ' 9. Districts'
		when 37 then '10. City'
		when  4 then '11. Publications'
		else sitename
		end

select s.siteid, sitename, propertyvalue
from t2k_site s
join t2k_siteproperties tsp
on s.siteid = tsp.siteid
where listsitepropertyid = 23285
and sitetype = 23150
order by 2

commit tran