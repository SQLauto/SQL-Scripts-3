begin tran

	delete from descheduledetail

	insert into deScheduleDetail ( 
		  [SDM_District]
		, [SDM_MessageTargetId]
		, [SDM_DayOfWeek]
		, [SDM_ExtensionAttribute1]
		, [SDM_HourBegin]			
		, [SDM_MinuteBegin]
		, [SDM_HourEnd]			
		, [SDM_MinuteEnd]		
		, [SDM_IsActive]
		, [SDM_ScheduleId]
	)	
	select 
		SDM_District as [SDM_District]
		, null as [SDM_MessageTargetId]
		, dow.DayNumber as [SDM_DayOfWeek]
		, null as [SDM_ExtensionAttribute1]
		, 6 as [SDM_BeginHour]
		, 0 as [SDM_BeginMinute]
		, 10 as [SDM_HourEnd]
		, 00 as [SDM_MinuteEnd]
		, 1 as [SDM_IsActive]
		, s.ScheduleId as [SDM_ScheduleId]
	from deDistrict
	join dd_nsdayofweek dow
			on 1 = 1
	--join deMessageTarget mt
	--	on tmp.Driver = mt.MessageTargetDisplayName		
	join deSchedule s
		on 1 = 1	
	--order by tmp.Town, DayNumber, ScheduleId
	order by 1
	
rollback tran	