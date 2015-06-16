use sdmconfig

begin tran

select sitename, propertyvalue
from t2k_siteproperties tsp
join t2k_site ts
on tsp.siteid = ts.siteid
where tsp.listsitepropertyid = 23288


update t2k_siteproperties
set propertyvalue =  '[SDM_MessageStatusID] NOT IN (5,6) AND datediff(d, [SDM_MessageDateTime], getdate()) = 0'-- [SDM_MessageDateTime] > cast(current_timestamp as varchar(8))'
from t2k_site ts
join t2k_siteproperties tsp
	on  ts.siteid = tsp.siteid
where ts.sitename = 'Message'
and tsp.listsitepropertyid = 23288

/*
update t2k_siteproperties
set propertyvalue =  '[SDM_MessageStatusID] NOT IN (6,7) AND datediff(d, [SDM_MessageDateTime], getdate()) = 0'
from t2k_site ts
join t2k_siteproperties tsp
	on  ts.siteid = tsp.siteid
where ts.sitename = 'DC Msgs'
and tsp.listsitepropertyid = 23288
*/

select sitename, propertyvalue
from t2k_siteproperties tsp
join t2k_site ts
on tsp.siteid = ts.siteid
where tsp.listsitepropertyid = 23288

commit tran

