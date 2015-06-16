begin tran

	if not exists ( select 1 from nsCompany where SDM_Company = 'Default' )
	begin
		insert into nsCompany ( SDM_Company, SDM_CompanyDisplayName, SDM_IsActive )
		select 'Default', 'Default', 1
	end
		
	if not exists ( select 1 from deDistributionCenter where SDM_DistributionCenter = 'Default' )
	begin
		insert into deDistributionCenter ( SDM_Company, SDM_DistributionCenter, SDM_DistributionCenterDisplayName, SDM_IsActive )
		select 'Default', 'Default', 'Default', 1
	end

	create table #schedules ( ScheduleDisplayName nvarchar(50), DistributionCenter nvarchar(25), CurrentSchedule bit)
	insert into #schedules ( ScheduleDisplayName, DistributionCenter, CurrentSchedule )
	select 'Default', 'Default', 0
	union all select 'Active', 'Active', 1
	
	insert into deSchedule ( ScheduleDisplayName, DistributionCenter, CurrentSchedule )
	select tmp.ScheduleDisplayName, tmp.DistributionCenter, tmp.CurrentSchedule
	from deSchedule s
	right join #schedules tmp
		on s.ScheduleDisplayName = tmp.ScheduleDisplayName
		and s.DistributionCenter = tmp.DistributionCenter

	drop table #schedules

commit tran	
