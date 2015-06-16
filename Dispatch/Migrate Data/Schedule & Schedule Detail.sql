

set identity_insert SDMData..deSchedule on

insert into SDMData..deSchedule (ScheduleID, ScheduleDisplayName, DistributionCenter, CurrentSchedule )
select ScheduleId,dc2.sdm_DistributionCenter,dc2.sdm_DistributionCenter,1 
from SDMData_CCT..Schedule s
join SDMData_CCT..DistributionCenter dc
	on s.DistributionCenterId = dc.DistributionCenterId 
join SDMData..deDistributionCenter dc2
	on dc.name = dc2.sdm_distributioncenterdisplayname

set identity_insert SDMData..deSchedule off

insert into SDMData..deScheduleDetail ( SDM_Company, SDM_DayofWeek, SDM_DistributionCenter, SDM_District, SDM_HourBegin, SDM_HourEnd, SDM_IsActive, SDM_MessageTargetID, SDM_MinuteBegin, SDM_MinuteEnd, SDM_ScheduleID, SDM_Zone )
select null, DayOfWeekID, s.DistributionCenter, ZoneNumber, ScheduleBeginHour, ScheduleEndHour, SDM_IsActive, MessageTargetId, ScheduleBeginMinute, ScheduleEndMinute, sd.ScheduleID, null
from sdmdata_cct..scheduledetail sd
join sdmdata..deschedule s
	on sd.scheduleid = s.scheduleid
