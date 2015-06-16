begin tran

	declare @oldmessagetarget nvarchar(50)
	declare @newmessagetarget nvarchar(50)

	set @oldmessagetarget = '6787774864@tmomail.net'
	set @newmessagetarget = 'ncobb44@ajc.com'

	select MessageTargetID
	from deMessageTarget mt
	where SyncronexUserName = @oldmessagetarget

	select MessageTargetID
	from deMessageTarget mt
	where SyncronexUserName = @newmessagetarget

	select SyncronexUserName, s.ScheduleDisplayName, COUNT(*)
	from deSchedule s
	join deScheduleDetail sd
		on s.ScheduleID = sd.SDM_ScheduleID
	join deMessageTarget mt
		on sd.SDM_MessageTargetID = mt.MessageTargetID
	where s.ScheduleDisplayName = 'Default'
	and mt.SyncronexUserName in ( @oldmessagetarget, @newmessagetarget )
	group by SyncronexUserName, s.ScheduleDisplayName

	update deScheduleDetail
	set SDM_MessageTargetID = ( 
		select mt.MessageTargetID
		from deMessageTarget mt
		where SyncronexUserName = @newmessagetarget
		)
	from deSchedule s
	join deScheduleDetail sd
		on s.ScheduleID = sd.SDM_ScheduleID
	join deMessageTarget mt
		on sd.SDM_MessageTargetID = mt.MessageTargetID
	where s.ScheduleDisplayName = 'Default'
	and sd.SDM_MessageTargetID = ( 
		select mt.MessageTargetID
		from deMessageTarget mt
		where SyncronexUserName = @oldmessagetarget
		)



	select SyncronexUserName, s.ScheduleDisplayName, COUNT(*)
	from deSchedule s
	join deScheduleDetail sd
		on s.ScheduleID = sd.SDM_ScheduleID
	join deMessageTarget mt
		on sd.SDM_MessageTargetID = mt.MessageTargetID
	where s.ScheduleDisplayName = 'Default'
	and mt.SyncronexUserName in ( @oldmessagetarget, @newmessagetarget )
	group by SyncronexUserName, s.ScheduleDisplayName

rollback tran
