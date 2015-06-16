if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[scForecastEngine_Run_DateRange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[scForecastEngine_Run_DateRange]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

create procedure [dbo].[scForecastEngine_Run_DateRange]
	  @beginDate_DaysOut int = 1
	, @endDate_DaysOut int = 1
	, @LoggingLevel varchar(2) = '0'
	, @LogToSystemLog bit = 1
	, @LogToMessages bit = 1
AS
/*=========================================================
-- $History: /Gazette/Database/Scripts/Sprocs/dbo.scForecastEngine_Run.PRC $
-- 
-- ****************** Version 2 ****************** 
-- User: jpeaslee   Date: 2008-11-13   Time: 10:47:37-08:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Remove scForecastEngine_ControlPanel_InsertAll 
-- 
-- ****************** Version 1 ****************** 
-- User: jpeaslee   Date: 2008-08-11   Time: 15:31:48-07:00 
-- Updated in: /Gazette/Database/Scripts/Sprocs 
-- Forecast overhaul 

Runs the forecast engine by updating the appropriate rows in merc_ControlPanel

=========================================================*/
BEGIN
  	declare @beginDate varchar(10)
	declare @endDate varchar(10)
	
	set @begindate = convert(varchar, dateadd(d, @beginDate_DaysOut, getdate()), 1)
	set @enddate = convert(varchar, dateadd(d, @endDate_DaysOut, getdate()), 1)
	
	--|print 'Begin Date: ' + @beginDate
	--|print 'Begin Date: ' + @endDate
	
	if not exists ( 
		select 1 as [ForecastEngineRunning]
		from merc_ControlPanel 
		where AppLayer = 'ForecastEngine'
		and AttributeName = 'EngineLock'
		and AttributeValue = 'True' 
	)
	begin
		if ( @LogToSystemLog = 1 or @LogToMessages = 1 )
		begin
			--| Insert an informational message into the System Log
			declare @msg varchar(256)
			set @msg = 'Auto-Forecast beginning for date range ''' + @beginDate + ''' to ''' + @endDate + '''.'
			exec syncSystemLog_Insert @moduleId=2,@SeverityId=0,@CompanyId=1,@Message=@msg
			--|print @msg
		
			declare @date datetime
			set @date = getdate()
			
			if @LogToSystemLog = 1
			begin
				exec syncSystemLog_Insert 2, 0, 1, @msg
			end

			if @LogToMessages = 1
			begin
				exec nsMessages_INSERTNOTALREADY 
					@nsSubject='Auto-Forecast'
					, @nsMessageText=@msg
					, @nsFromId = 8
					, @nsToId = 0
					, @nsGroupId = 2
					, @nsTime = @date
					, @nsPriorityId = 2 	--|  Normal
					, @nsStatusId = 3  	--|
					, @nsTypeId = 1		--|  Memo 
					, @nsStateId = 1
					, @nsCompareTime = @date
					, @nsAccountId = 0
			end
		end
	
		update merc_ControlPanel
		set AttributeValue = case AttributeName
			when 'BeginDate' then @beginDate
			when 'EndDate' then @endDate
			when 'LoggingLevel' then '0'
			when 'LogFile' then NULL
			when 'DiagnosticOutput' then 'False'
			when 'EngineRequest' then 'true'
			when 'UserName' then 'Scheduled Job'
			when 'UserId' then '-1'
			when 'LastStatus' then ''
			when 'OverwriteUserEdits' then 'False'
			else AttributeValue
			end
		where AppLayer = 'ForecastEngine'
	end
	
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

/*
	exec scForecastEngine_Run_DateRange @beginDate_DaysOut=1, @endDate_DaysOut=1, @LoggingLevel='0', @LogToSystemLog=1, @LogToMessage=1
*/