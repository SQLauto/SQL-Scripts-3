begin tran

/*
ListSitePropertyID
------------------
1	Image Path
2	CSS Path
3	UNC Path
4	URL Path
5	UNC Template Path
6	Script Path
7	EDR Connection String
8	Config DB Connection String
9	View Admin Email Address
14	Primary Color
15	Accent Color
17	Odd Table Cell Color
18	Even Table Cell Color
23284	Encrypt View
23285	Hide View
23286	Logon Required to Access View
23287	Allow Owner Delete
23288	View Filter
23289	Session Timeout
*/

declare @listsitepropertyid int
set @listsitepropertyid = 4

select *
from sdmconfig..t2k_siteproperties
where listsitepropertyid = @listsitepropertyid 
order by listsitepropertyid

update sdmconfig..t2k_siteproperties
set propertyvalue = replace(propertyvalue, '/NewspaperSuite/', '/Dispatch/')
where listsitepropertyid = @listsitepropertyid  

select *
from sdmconfig..t2k_siteproperties
where listsitepropertyid = @listsitepropertyid 
order by listsitepropertyid

--rollback tran
commit tran

