begin tran

select siteid, ListSitePropertyID, PropertyValue as [propertyvalue]
into #prev
from sdmconfig..t2k_siteproperties 
where ListSitePropertyID in (7,8)
and siteid in (
	select siteid
	from sdmconfig..t2k_site
	where sitetype = 23151
	and isactive = 1
)

update sdmconfig..t2k_siteproperties
--set propertyvalue = 'Provider=SQLNCLI10.1;Persist Security Info=True;User ID=dmconfig;password=dmconfig;Initial Catalog=SDMData;Data Source=S1;'
set propertyvalue = 'Provider=SQLOLEDB; Data Source=PUfFIN; Initial Catalog=SDMData; User ID=dmconfig; Password=dmconfig'
where ListSitePropertyID in (7)
and siteid in (
	select siteid
	from sdmconfig..t2k_site
	where sitetype = 23151
	and isactive = 1
)

update sdmconfig..t2k_siteproperties
--set propertyvalue = 'Provider=SQLNCLI10.1;Persist Security Info=True;User ID=dmconfig;password=dmconfig;Initial Catalog=SDMConfig;Data Source=S1;'
set propertyvalue = 'Provider=SQLOLEDB; Data Source=PUfFIN; Initial Catalog=SDMConfig; User ID=dmconfig; Password=dmconfig'
where ListSitePropertyID in (8)
and siteid in (
	select siteid
	from sdmconfig..t2k_site
	where sitetype = 23151
	and isactive = 1
)

select tsp.ListSitePropertyID
	,prv.PropertyValue as [OldValue]
	,tsp.PropertyValue as [NewValue]
from sdmconfig..t2k_siteproperties tsp
join #prev prv
on tsp.listsitepropertyid = prv.listsitepropertyid
	and tsp.siteid = prv.siteid
where tsp.ListSitePropertyID in (7,8)
and tsp.siteid in (
	select siteid
	from sdmconfig..t2k_site
	where sitetype = 23151
	and isactive = 1
)

drop table #prev

commit tran

