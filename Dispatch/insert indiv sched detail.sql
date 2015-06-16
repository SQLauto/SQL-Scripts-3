begin tran

declare  @company varchar(255)
	,@distributioncenter varchar(255)
	,@district varchar(255)
	,@extensionattribute1 varchar(255)
	,@extensionattribute2 varchar(255)
	,@hourbegin varchar(255)
	,@hourend varchar(255)
	,@messagetarget varchar(255)
	,@messagetargetid varchar(255)
	,@minutebegin varchar(255)
	,@minuteend varchar(255)
	,@route varchar(255)
	,@scheduleid varchar(255)
	,@zone varchar(255)

set @district = 'N170'
set @messagetarget = 'mjordan@seattletimes.com'
set @hourbegin = 10
set @hourend = 12
set @minutebegin = 0
set @minuteend = 0
set @scheduleid = 8

select @messagetargetid = messagetargetid
from demessagetarget
where syncronexusername = @messagetarget

insert into descheduledetail
(
sdm_company
,sdm_dayofweek
,sdm_distributioncenter
,sdm_district
,sdm_extensionattribute1
,sdm_extensionattribute2
,sdm_hourbegin
,sdm_hourend
,sdm_messagetargetid
,sdm_minutebegin
,sdm_minuteend
,sdm_route
,sdm_scheduleid
,sdm_zone
)
select @company, 1, @distributioncenter, @district, @extensionattribute1, @extensionattribute2, @hourbegin, @hourend, @messagetargetid, @minutebegin, @minuteend, @route, @scheduleid, @zone
union all 
select @company, 2, @distributioncenter, @district, @extensionattribute1, @extensionattribute2, @hourbegin, @hourend, @messagetargetid, @minutebegin, @minuteend, @route, @scheduleid, @zone
union all 
select @company, 3, @distributioncenter, @district, @extensionattribute1, @extensionattribute2, @hourbegin, @hourend, @messagetargetid, @minutebegin, @minuteend, @route, @scheduleid, @zone
union all 
select @company, 4, @distributioncenter, @district, @extensionattribute1, @extensionattribute2, @hourbegin, @hourend, @messagetargetid, @minutebegin, @minuteend, @route, @scheduleid, @zone
union all 
select @company, 5, @distributioncenter, @district, @extensionattribute1, @extensionattribute2, @hourbegin, @hourend, @messagetargetid, @minutebegin, @minuteend, @route, @scheduleid, @zone
union all 
select @company, 6, @distributioncenter, @district, @extensionattribute1, @extensionattribute2, @hourbegin, @hourend, @messagetargetid, @minutebegin, @minuteend, @route, @scheduleid, @zone
union all 
select @company, 7, @distributioncenter, @district, @extensionattribute1, @extensionattribute2, @hourbegin, @hourend, @messagetargetid, @minutebegin, @minuteend, @route, @scheduleid, @zone

select *
from descheduledetail 
where sdm_district = @district

commit tran