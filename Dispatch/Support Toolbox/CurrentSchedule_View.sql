IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[currentSchedule]'))
DROP VIEW [dbo].[currentSchedule]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[currentSchedule]
as

	with currentSchedule
	as (
		select 
			  sd.SDM_District				as [District]
			, sd.SDM_ExtensionAttribute1	as [Route]
			, dow.DayName
			, dow.DayNumber	
			, convert( varchar, 
				cast( right( '00' + cast( + sd.SDM_HourBegin as varchar), 2) + ':' + right('00' + cast(sd.SDM_MinuteBegin as varchar),2) as datetime)
				 , 114) as [start]
			, convert( varchar, 
				cast( right( '00' + cast( + sd.SDM_HourEnd as varchar), 2) + ':' + right('00' + cast(sd.SDM_MinuteEnd as varchar),2) as datetime)
				 , 114)	  as [end]
			, CONVERT(varchar, getdate(), 114) as [CurrentTime]	 
			, sd.SDM_MessageTargetID	 
			, mt.MessageTargetDisplayName, mt.SyncronexUserName
		from deSchedule s
		join deScheduleDetail sd
			on s.ScheduleID = sd.SDM_ScheduleID
		join dd_nsDayofWeek dow
			on sd.SDM_DayofWeek = dow.DayNumber	
		join deMessageTarget mt
			on sd.SDM_MessageTargetID = mt.MessageTargetID	
		where s.CurrentSchedule = 1
	)
	select *
	from currentSchedule
	where DATEPART(DW, GETDATE()) = [DayNumber]
	and CONVERT(varchar, getdate(), 114) between start and [end]

GO

select *
from currentSchedule