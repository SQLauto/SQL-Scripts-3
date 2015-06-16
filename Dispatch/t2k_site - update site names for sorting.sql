begin tran

update t2k_site
set sitename = case sitename
		when 'Message' then '1) Message'
		when 'Schedule Detail' then '2) Schedule Detail'
		when 'Message Target' then '3) Message Target'
		when 'System Log' then '4) System Log'
		when 'Company' then '5) Company'
		when 'Distribution Centers' then '6) Distribution Centers'
		when 'Zones' then '7) Zones'
		when 'Districts' then '8) Districts'
		when 'City' then '9) City'
		when 'Zip Codes' then '10) Zip Codes'
		else sitename
		end

select sitename, propertyvalue
from t2k_site s
join t2k_siteproperties tsp
on s.siteid = tsp.siteid
where listsitepropertyid = 23285
and sitetype = 23150
order by 1

rollback tran