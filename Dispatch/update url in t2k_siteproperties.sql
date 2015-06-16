begin tran

declare @WebServerName varchar(50)

select @WebServerName = 
	substring( propertyvalue
	, charindex('http://', propertyvalue, 0) + len('http://')
	, charindex('/', propertyvalue, charindex('http://', propertyvalue, 0) ) + 1 ) 
from sdmconfig..t2k_siteproperties 
where ListSitePropertyID = 4

select siteid, ListSitePropertyID, PropertyValue as [propertyvalue]
into #prev
from sdmconfig..t2k_siteproperties 
where ListSitePropertyID = 4

update sdmconfig..t2k_siteproperties
set propertyvalue = replace(propertyvalue, @WebServerName, lower(@@servername))
where listsitepropertyid = 4

select tsp.ListSitePropertyID
	,prv.PropertyValue as [OldValue]
	,tsp.PropertyValue as [NewValue]
from sdmconfig..t2k_siteproperties tsp
join #prev prv
on tsp.listsitepropertyid = prv.listsitepropertyid
	and tsp.siteid = prv.siteid
where tsp.ListSitePropertyID = 4

commit tran