begin tran

delete deScheduleDetail
from deScheduleDetail sd
where SDM_Zone = 'RCKDLE'
and SDM_IsActive = 0
and SDM_ScheduleID = 8

;with cte as (
	select sd.SDM_ScheduleID
	, sd.SDM_Zone
	, sd.SDM_District
	, isnull(sd.SDM_Route,'') as [SDM_Route]
	, SDM_IsActive
	, 2 as dw
	, SDM_HourBegin, SDM_MinuteBegin
	, SDM_HourEnd, SDM_MinuteEnd
	, SDM_MessageTargetID
	--, SDM_Company, SDM_DistributionCenter, SDM_ExtensionAttribute1, SDM_ExtensionAttribute2
	from deScheduleDetail sd
	where SDM_Zone = 'RCKDLE'
	and SDM_IsActive = 1
	and SDM_ScheduleID = 8
	
	union all 
	select SDM_ScheduleID
		, SDM_Zone
		, SDM_District
		, isnull(SDM_Route,'') as [SDM_Route]
		, SDM_IsActive
		, dw + 1 as dw
		, SDM_HourBegin, SDM_MinuteBegin
		, SDM_HourEnd, SDM_MinuteEnd
		, SDM_MessageTargetID
		from cte
		where dw + 1 < 8
)
insert into deScheduleDetail (SDM_ScheduleID
	, SDM_Zone
	, SDM_District
	, SDM_Route
	, SDM_IsActive
	, SDM_DayofWeek
	, SDM_HourBegin, SDM_MinuteBegin
	, SDM_HourEnd, SDM_MinuteEnd
	, SDM_MessageTargetID 
	, SDM_ExtensionAttribute2)
select SDM_ScheduleID
	, SDM_Zone
	, SDM_District
	, SDM_Route
	, SDM_IsActive
	, dw
	, SDM_HourBegin, SDM_MinuteBegin
	, SDM_HourEnd, SDM_MinuteEnd
	, SDM_MessageTargetIDa
	, 'Support 1/10/2014'
from cte
order by SDM_ScheduleID
		, SDM_Zone
		, SDM_District
		, SDM_Route
		, dw

commit tran